
#import "NSURLSession+SynchronousTask.h"
#import "TAPSummonerManager.h"
#import "TAPDataManager.h"
#import "TAPUtil.h"
#import "Summoner.h"
#import "Match.h"


@interface TAPSummonerManager()
{
    dispatch_queue_t loadQueue;
    
    long newestLoadedMatchId;
    long newestSavedMatchId;
    
    int lastFetchIndex;
    BOOL registered;
}

//summoner
@property (nonatomic, strong) Summoner *summoner;
- (void)setSummonerIfRegistered;

//matches
@property (nonatomic, strong) NSDate *lastFetch;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSMutableArray *mutableMatches;
@property (nonatomic, strong) NSMutableArray *temporaryMatches;

//intermediate
- (int)loadFromLocal;
- (int)loadFromServer;

//helpers
- (BOOL)hasSavedMatches;
- (void)saveMatches:(NSArray *)matches;
- (NSArray *)matchHistoryFrom:(int)index;

@end
#pragma mark -



@implementation TAPSummonerManager
#pragma mark Init
/**
 * @method initWithSummoner
 *
 * Only way to init a SummonerManager is with a summoner.
 * Summoner data should be complete with region, too.
 */
- (instancetype)initWithSummoner:(NSDictionary *)summonerInfo
{
    if (self = [super init])
    {
        self.mutableMatches = [[NSMutableArray alloc] init];
    
        //set summonerInfo to given one & set registered
        self.summonerInfo = summonerInfo;
        [self setSummonerIfRegistered];
        
        //numbers to keep track
        newestLoadedMatchId = -1;
        lastFetchIndex = 0;
        
        //make ephemeral session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        //create queue name "<summonerName> queue" for API calls
        const char *loadLabel  = [[NSString stringWithFormat:@"%@ load queue", summonerInfo[@"name"]] UTF8String];
        loadQueue = dispatch_queue_create(loadLabel, DISPATCH_QUEUE_CONCURRENT);
        
        NSLog(@"data location: %@", [self applicationDocumentsDirectory]);
    }
    return self;
}

/**
 * @method setSummonerIfRegistered
 *
 * Fetches summoner entities with id.
 * If registered, sets self.summoner to object or nil if not found.
 * Sets registered accordingly.
 *
 * @note One time method to be called in init.
 *       Only other time registered should change is when
 *       registerSummoner or deregisterSummoner
 */
- (void)setSummonerIfRegistered
{
    registered = NO;
    self.summoner = nil;
    newestSavedMatchId = -1;
    
    // fetch for summoner entity with summonerId
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    [summonerFetch setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.summonerInfo[@"id"]]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    
    if (error || result.count == 0)
    {
        NSLog(@"%@", !error ? @"No registered summoner" : [NSString stringWithFormat:@"Fetch error: %@", error]);
        return;
    }
    
    registered = YES;
    self.summoner = [result firstObject];
    if ([self hasSavedMatches])
        newestSavedMatchId = [((Match*)[self.summoner.matches lastObject]).matchId longValue];
}


#pragma mark - Accessors
/**
 * @method loadedMatches
 *
 * Returns a NSArray poiner to mutablesMatches.
 * @note Assume that the receiver is responsible enough
 *       to actually treat the pointer as an immutable array.
 *
 * @return NSArray pointer to mutableMatches
 */
- (NSArray *)loadedMatches
{
    return (NSArray *)self.mutableMatches;
}


#pragma mark - Account
/**
 * @method registerSummoner
 *
 * Adds new summoner entity to core data
 * with the given data & 0 as lastMatchId.
 * Sets self.summoner & registered to true.
 */
- (void)registerSummoner
{
    //if not registered
    if (!registered)
    {
        NSLog(@"registerSummoner %@", self.summonerInfo);
        self.summoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner"
                                                      inManagedObjectContext:self.managedObjectContext];
        
        [self.summoner setValue:self.summonerInfo[@"region"] forKey:@"region"];
        [self.summoner setValue:self.summonerInfo[@"name"]   forKey:@"name"];
        [self.summoner setValue:self.summonerInfo[@"id"]     forKey:@"id"];
        
        registered = YES;
        [self saveContext];
    }
}

/**
 * @method deregisterSummoner
 *
 * Deletes the current summoner object from core data.
 * Sets registered to false & summoner to nil.
 */
- (void)deregisterSummoner
{
    if (registered)
    {
        [self.managedObjectContext deleteObject:self.summoner];
        [self saveContext];
    
        self.summoner = nil;
        registered = NO;
    }
}



#pragma mark - Public Load Methods
/**
 * @method initalLoad
 *
 * Loads the first 15 matches for this summoner on a background queue
 * and reports back to the delegate with number actually loaded.
 *
 */
- (void)initalLoad
{
    //if no internet && registered has saved matches
        //load 15 from core data
        //report back to delegate
    
    //for now assume internet
    dispatch_async(loadQueue,
    ^{
        //load 15 from server
        int index = 0;
        NSArray *newestMatches = [self matchHistoryFrom:index];
        
        NSLog(@"newestFetched:%@", [newestMatches firstObject][@"matchId"]);
        
        //set data
        index += newestMatches.count;
        [self.mutableMatches addObjectsFromArray:newestMatches];
        newestLoadedMatchId = [[self.mutableMatches firstObject][@"matchId"] longValue];
        
        //report to delegate
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.delegate didFinishInitalLoadMatches:(int)self.mutableMatches.count];
        });
        
        //first time registered
        if (registered && ![self hasSavedMatches])
        {
            NSArray *remaining = [self fetchUntilUpdatedFrom:index];
            [self saveMatches:remaining];
            [self saveMatches:newestMatches];
        }
    });
}

/**
 * @method loadNewMatches
 *
 * Retreives the latest 15 matches for this summoner from server
 * removes any overlaps and reports back to delgate with number of matches actually loaded.
 */
- (void)loadNewMatches
{
    dispatch_async(loadQueue,
    ^{
        NSMutableArray *newMatches;
        int numLoaded  = 0;
        
        //depends on registered
        if (registered)
        {
            newMatches = [self fetchUntilUpdatedFrom:0];
            numLoaded = (int)newMatches.count;
            
            [self saveMatches:newMatches];
        }
        else
        {
            newestLoadedMatchId = [[self.temporaryMatches firstObject][@"matchId"] longValue];
            newMatches = [self fetchUntilUpdatedFrom:0];
            numLoaded = (int)newMatches.count;
            
            [newMatches addObjectsFromArray:self.temporaryMatches];
            [self.temporaryMatches removeAllObjects];
        }
        
        //set
        if (numLoaded > 0)
        {
            newestLoadedMatchId = [[newMatches firstObject][@"matchId"] longValue];
            [newMatches addObjectsFromArray:self.mutableMatches];
            self.mutableMatches = newMatches;
        }
        
        //report to delegate
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.delegate didFinishLoadingNewMatches:numLoaded];
        });
    });
}

/**
 * @method loadOldMatches
 *
 * Loades the next 15 matches for this summoner from local
 * and reports back to delegate with number of matches actually loaded.
 */
- (void)loadOldMatches
{
    NSLog(@"-[SummonerManager loadOldMatches]");
    dispatch_async(loadQueue,
    ^{
        int numLoaded = registered ? [self loadFromLocal] : [self loadFromServer];
        
        //report to delegate
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.delegate didFinishLoadingOldMatches:numLoaded];
        });
    });
}

#pragma mark - Private Intermeidate Methods
/**
 * @method loadFromLocal
 *
 * Loads the next set of matches from core data.
 * Tries to load max of 15 at a time,
 * and returns nil array if no more matches should be loaded.
 * @note Assumed that this method is called from background queue
 *       and that summoner is registered and set.
 *
 * @return int value of number of matches loaded
 */
- (int)loadFromLocal
{
    NSLog(@"-[SummonerManager loadFromLocal]");
    
    int saved   = (int)self.summoner.matches.count;
    int loaded  = (int)self.mutableMatches.count;
    int numLoad = (int)MIN(15, saved - loaded);
    int startIndex = saved - loaded - 1;
    
    NSMutableArray *oldMatches = [[NSMutableArray alloc] init];
    for (int i = startIndex; i >= startIndex - numLoad; i--)
    {
        //get match entity
        Match* match = [self.summoner.matches objectAtIndex:i];
        
        //create and set readable dictionary
        NSMutableDictionary *matchDict = [[NSMutableDictionary alloc] init];
        for (NSPropertyDescription *property in [NSEntityDescription entityForName:@"Match" inManagedObjectContext:self.managedObjectContext])
        {
            if (![property.name isEqual:@"summoner"])
                [matchDict setValue:[match valueForKey:property.name] forKey:property.name];
        }
        
        [oldMatches addObject:matchDict];
    }
    
    [self.mutableMatches addObjectsFromArray:oldMatches];
    
    return numLoad;
}

/**
 * @method loadFromServer
 *
 * Loads the next 15 matches from server.
 * 
 * This is trickier than -[loadFromLocal] because local can
 * load the next 15 from core data whatever the newest match.
 * However, if summoner played more games since the last update,
 * fetching from where it left off gives overlaps.
 *
 * For this reason, summoner's newest matches until overlap are loaded,
 * and then stored in a temporary mutable array of matches.
 * Then, the next fetch index becomes the total size of loaded + stored matches.
 * The next 15 matches for unregistered summoner are fetched from that index.
 *
 * @return int value of number of OLDER matches loaded
 */
- (int)loadFromServer
{
    //update newest to temp
    NSMutableArray *newestMatches = [self fetchUntilUpdatedFrom:0];
    [newestMatches addObjectsFromArray:self.temporaryMatches];
    self.temporaryMatches = newestMatches;
    
    //get index to fetch from
    int index = (int)( self.temporaryMatches.count + self.mutableMatches.count );
    NSArray *oldMatches = [self matchHistoryFrom:index];
    
    //add to loaded
    int numLoaded = (int)oldMatches.count;
    [self.mutableMatches addObjectsFromArray:oldMatches];
    
    return numLoaded;
}

/**
 * @method loadFromServer:
 * 
 * Calculates index range of the specified number of next oldest matches.
 * Increments endMatchIndex accordingly and returns matches fetched by
 * matchHistoryFrom:To:
 *
 * @return NSArray of matches in reverse chronological order
 */
- (NSArray *)loadFromServer:(int)numberOfMatches
{
    NSLog(@"[loadFromServer:]");
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    while (numberOfMatches > 0)
    {
        int fetchLimit = (int)MIN(15, numberOfMatches);
        int count = (int)matches.count;
        [matches addObjectsFromArray:[self matchHistoryFrom:count to:count + fetchLimit]];
        
        numberOfMatches -= fetchLimit;
    }
    return matches;
}

/**
 * @method fetchUntilUpdatedFrom:
 *
 * Fetches from MatchHistoryAPI until overlapping MatchId is found.
 * The newest matchId to compare is set depending on if registered.
 *
 * @param index - to start fetching from
 * @return NSMutableArray of not yet updated matches
 */
- (NSMutableArray *)fetchUntilUpdatedFrom:(int)index
{
    NSLog(@"-[SummonerManger fetchUntilUpdatedFrom]");
    
    long limit = registered ? newestSavedMatchId : newestLoadedMatchId;
    NSMutableArray *newMatches = [[NSMutableArray alloc] init];
    
    //fetch while no overlap
    int numAdded = 0;
    do
    {
       NSArray *fetchedMatches = [self matchHistoryFrom:index];
       index += 15;
       
       for (NSDictionary *matchDict in fetchedMatches)
       {
           if (limit < [matchDict[@"matchId"] longValue])
           {
               [newMatches addObject:matchDict];
               numAdded++;
           }
        }
        numAdded = 0;
    }
    while (numAdded >= 15);
    
    return newMatches;
}

#pragma mark - Core Data Helpers
/**
 * @method hasSavedMatches
 *
 * Checks whether registered summoner has stored mathces,
 * which implies that summoner is reigstered.
 *
 * @return YES if summoner has stored matches.
 */
- (BOOL)hasSavedMatches
{
    return registered && ([self.summoner.matches count] > 0);
}

/**
 * @method saveMatches
 *
 * Saves given matches into core data for summoner.
 * @note Given array of matches should not contain
 *       overlaps with currently stored match history.
 *
 * @param matches - new matches to be saved
 */
- (void)saveMatches:(NSArray *)matches
{
    long oldestGiven = [[matches lastObject][@"matchId"] longValue];
    if (newestSavedMatchId >= oldestGiven)
        return;
    
    //set iVars
    newestSavedMatchId = [[matches lastObject][@"matchId"] longValue];
    
    //retreive mutable set
    NSMutableOrderedSet *orderedMatchSet = [self.summoner mutableOrderedSetValueForKey:@"matches"];
    
    //create match entity
    NSEnumerator *reverseEnum = [matches reverseObjectEnumerator];
    NSDictionary *matchDict;
    while ( matchDict = [reverseEnum nextObject] )
    {
        Match *newMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Match" inManagedObjectContext:self.managedObjectContext];
        
        for (NSString *key in [matchDict allKeys])
            [newMatch setValue:[matchDict valueForKey:key] forKey:key];
        newMatch.summoner = self.summoner;
        newMatch.summonerIndex = @0;
        newMatch.teams = @[];
        
        //add to set
        [orderedMatchSet addObject:newMatch];
    }
    
    [self saveContext];
}

#pragma mark - Match History API
/**
 * @method matchHistoryFrom:
 *
 * Gets match history from [index, index+15) using MatchHistoryAPI
 *
 * @param index - to start fetch from
 * @return NSArray of the requested match history
 */
- (NSArray *)matchHistoryFrom:(int)index
{
    return [self matchHistoryFrom:index to:index+15];
}

/**
 * @method matchHistoryFrom: to:
 *
 * Given a range, fetches [begin, end) from MatchHistoryAPI.
 * The resulting array might not be (end - begin) matches
 * if summoner does not have that many matches starting at index begin
 *
 * @note MatchHistoryAPI gives the array of matches in chronological order.
 *       The array given by this method is in reverse chronological order.
 *
 * @note This method is synchronous and should be called accordingly.
 *
 * @param begin - index to fetch from
 * @param end   - index to fetch from
 * @return NSArray of the requested match history
 */
- (NSArray *)matchHistoryFrom:(int)begin to:(int)end
{
    if (begin > end)
        return nil;

    NSLog(@"matchHistoryFrom:%d to:%d", begin, end);
    NSString *beginIndex = [NSString stringWithFormat:@"beginIndex=%d", begin];
    NSString *endIndex   = [NSString stringWithFormat:@"endIndex=%d", end];
    NSURL *url = apiURL(kLoLMatchHistory, self.summonerInfo[@"region"], [self.summonerInfo[@"id"] stringValue], @[beginIndex, endIndex]);
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [self.urlSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *matchHistory = [[dataDict[@"matches"] reverseObjectEnumerator] allObjects];
    
    return matchHistory;
}

@end
