
#import "NSURLSession+SynchronousTask.h"
#import "TAPSummonerManager.h"
#import "TAPDataManager.h"
#import "Constants.h"
#import "Summoner.h"
#import "Match.h"


@interface TAPSummonerManager()
{
    dispatch_queue_t loadQueue;
    
    long newestLoadedMatchId;
    long oldestLoadedMatchId;
    long newestSavedMatchId;
    long oldestSavedMatchId;
    
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
- (NSArray *)loadFromLocal;
- (NSArray *)loadFromServer;

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
        oldestLoadedMatchId = -1;
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
    oldestSavedMatchId = -1;
    
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
    {
        newestSavedMatchId = [((Match*)[self.summoner.matches lastObject]).matchId longValue];
        oldestSavedMatchId = [((Match*)[self.summoner.matches firstObject]).matchId longValue];
    }
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
        [self.summoner setValue:@0 forKey:@"lastMatchId"];
        
        registered = YES;
        [self saveContext];
    }
    //[[DataManager sharedManager] summonerDump];
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
    NSLog(@"-[SummonerManager initalLoad]");
    
    //if no internet && registered has saved matches
        //load 15 from core data
        //report back to delegate
    
    //for now assume internet
    dispatch_async(loadQueue,
    ^{
        //load 15 from server
        int index = 0;
        NSArray *newestMatches = [self matchHistoryFrom:index];
        
        //set data
        index += newestMatches.count;
        [self.mutableMatches addObjectsFromArray:newestMatches];
        oldestLoadedMatchId = [[self.mutableMatches lastObject][@"matchId"] longValue];
        newestLoadedMatchId = [[self.mutableMatches firstObject][@"matchId"] longValue];
        
        //report to delegate
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [self.delegate didFinishInitalLoadMatches:(int)self.mutableMatches.count];
        });
        
        if (registered)
        {
            NSArray *remaining = [self fetchUntilUpdatedFrom:index];
            [self saveMatches:remaining];
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
    //fetch 15 until no overlaps
    
    //if registered
        //save to core data
}

/**
 * @method loadOldMatches
 *
 * Loades the next 15 matches for this summoner from local
 * and reports back to delegate with number of matches actually loaded.
 */
- (void)loadOldMatches
{
    //if registered
        //load 15 from core data
    
    //not registered
        //load latest from server until no overlap -> store to temp
        //increment fetchIndex by that much
        //load 15 from that fetch index
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
 * @return NSArray of matches in reverse chronological
 */
- (NSArray *)loadFromLocal
{
    return nil;
}

/**
 * Returns the 15 next oldest matches for the summoner.
 *
 * @return NSArray of 15 matches in reverse chronological order
 */
- (NSArray *)loadFromServer
{
    return nil;
}

/**
 * Calculates index range of the specified number of next oldest matches.
 * Increments endMatchIndex accordingly and returns matches fetched by
 * matchHistoryFrom:To:
 *
 * @return NSArray of matches in reverse chronological order
 */
- (NSArray *)loadFromServer:(int)numberOfMatches
{
    NSLog(@"[loadFromServer]");
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    do
    {
        [matches addObjectsFromArray:[self matchHistoryFrom:lastFetchIndex]];
        lastFetchIndex += 15;
        numberOfMatches -= 15;
    }
    while(numberOfMatches > 15);
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
       
       numAdded = 0;
       for (NSDictionary *match in fetchedMatches)
           if (limit < [match[@"matchId"] longValue])
           {
               [newMatches addObject:fetchedMatches];
               numAdded++;
           }
    }
    while (numAdded >= 15);
    
    return newMatches;
}

#pragma mark - Private Fetch/Save Helpers
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
    //check last matchId is larger than newested saved matchId
        //add matches to Summoner's NSOrderedSet of matches
        //add matchIds to Summoner's NSMutableArray of matchIds
        //NOTE add NSMutableArray of MatchIds to Summoner.h
    
    //otherwise no
    [self saveContext];
}

/**
 * @method matchHistoryFrom:
 *
 * Given an index, fetches [index, index+15) from MatchHistoryAPI.
 * The resulting array might not be 15 matches
 * if summoner has less than 15 matches starting from index.
 *
 * @note MatchHistoryAPI gives the array of matches in chronological order.
 *       The array given by this method is in reverse chronological order.
 *
 * @note This method is synchronous and should be called accordingly.
 *
 * @param index - to start fetch from
 * @return NSArray of the requested match history
 */
- (NSArray *)matchHistoryFrom:(int)index
{
    NSLog(@"matchHistoryFrom:%d to:%d", index, index+15);
    NSString *beginIndex = [NSString stringWithFormat:@"beginIndex=%d", index];
    NSString *endIndex   = [NSString stringWithFormat:@"endIndex=%d", index+15];
    NSURL *url = apiURL(kLoLMatchHistory, self.summonerInfo[@"region"], [self.summonerInfo[@"id"] stringValue], @[beginIndex, endIndex]);
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [self.urlSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *matchHistory = [[dataDict[@"matches"] reverseObjectEnumerator] allObjects];
    
    return matchHistory;
}

@end
