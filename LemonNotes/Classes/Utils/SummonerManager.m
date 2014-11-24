
#import "NSURLSession+SynchronousTask.h"
#import "SummonerManager.h"
#import "DataManager.h"
#import "Constants.h"
#import "Summoner.h"
#import "Match.h"


@interface SummonerManager()

//Core Data
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)saveContext;

//summoner
@property (nonatomic, strong) NSDictionary *summonerInfo;
@property (nonatomic, strong) Summoner *summoner;
@property (nonatomic) BOOL isRegistered;
- (void)checkRegistered;

//matches
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) dispatch_queue_t loadQueue;
@property (nonatomic, strong) dispatch_queue_t fetchQueue;
@property (nonatomic) long newestStoredMatchId;
@property (nonatomic) long oldestLoadedMatchId;
@property (nonatomic) int lastFetchIndex;
- (void)saveMatches:(NSArray *)matches;
- (BOOL)hasSavedMatches;
- (NSArray *)loadFromLocal;
- (NSArray *)loadFromServer;
- (NSArray *)matchHistoryFrom:(int)begin To:(int)end;

@end


@implementation SummonerManager

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
        //set summonerInfo to given one & set isRegistered
        self.summonerInfo = summonerInfo;
        [self checkRegistered];
        
        //newestMatchId is id of last recorded game, or -1 if not registered
        //endMatchIndex is used for keeping track of index in API calls
        self.newestStoredMatchId = self.isRegistered ? [self.summoner.lastMatchId longValue] : 0;
        self.oldestLoadedMatchId = self.newestStoredMatchId;
        self.lastFetchIndex = 0;
        
        //make ephemeral session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        //create queue name "<summonerName> queue" for API calls
        const char *loadLabel  = [[NSString stringWithFormat:@"%@ load queue", summonerInfo[@"name"]] UTF8String];
        const char *fetchLabel = [[NSString stringWithFormat:@"%@ fetch queue", summonerInfo[@"name"]] UTF8String];
        self.loadQueue  = dispatch_queue_create(loadLabel, DISPATCH_QUEUE_CONCURRENT);
        self.fetchQueue = dispatch_queue_create(fetchLabel, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

/**
 * @method checkRegistered
 *
 * Fetches summoner entities with id.
 * If registered, sets self.summoner to object or nil if not found.
 * Sets self.isRegistered accordingly.
 * @note One time method to be called in init.
 *       Only other time isRegistered should change is when
 *       registerSummoner or deregisterSummoner
 */
- (void)checkRegistered
{
    // fetch for summoner entity with summonerId
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    [summonerFetch setPredicate:[NSPredicate predicateWithFormat:@"id == %@", self.summonerInfo[@"id"]]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    
    self.summoner = (result.count > 0) ? result[0] : nil;
    self.isRegistered = self.summoner != nil;
}

#pragma mark - Account
/**
 * @method registerSummoner
 *
 * Adds new summoner entity to core data
 * with the given data & 0 as lastMatchId.
 * Sets self.summoner & isRegistered to true.
 */
- (void)registerSummoner
{
    //if not registered
    if (!self.isRegistered)
    {
        self.summoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner"
                                                      inManagedObjectContext:self.managedObjectContext];
        
        [self.summoner setValue:self.summonerInfo[@"region"] forKey:@"region"];
        [self.summoner setValue:self.summonerInfo[@"name"]   forKey:@"name"];
        [self.summoner setValue:self.summonerInfo[@"id"]     forKey:@"id"];
        [self.summoner setValue:@0 forKey:@"lastMatchId"];
        
        self.isRegistered = YES;
        [self saveContext];
    }
    [[DataManager sharedManager] summonerDump];
}

/**
 * @method deregisterSummoner
 *
 * Deletes the current summoner object from core data.
 * Sets isRegistered to false & summoner to nil.
 */
- (void)deregisterSummoner
{
    [self.managedObjectContext deleteObject:self.summoner];
    [self saveContext];
    
    self.summoner = nil;
    self.isRegistered = NO;
}



#pragma mark - Recent Matches
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
    return self.isRegistered && ([self.summoner.matches count] > 0);
}

//get 15 of the latest matches from riot
//check if the latest match is newer than
- (void)refreshMatches
{
    dispatch_async(self.loadQueue,
    ^{
        self.newestStoredMatchId = 0; //temp while other things are set up
        
        //mutable array from fetched match history
        NSMutableArray *newMatches = [NSMutableArray arrayWithArray:[self matchHistoryFrom:0 To:15]];
        NSLog(@"count: %lu", (unsigned long)newMatches.count);
        for (int i = (int)(newMatches.count-1); i >= 0; i--)
        {
            NSDictionary *match = [newMatches objectAtIndex:i];
            if ([match[@"matchId"] longValue] <= self.newestStoredMatchId)
            {
                //remove any overlap matches with a match id equal/lower than current
                [newMatches removeObjectAtIndex:i];
            }
        }
        
        self.lastFetchIndex += (int)newMatches.count;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFinishRefreshingMatches:[newMatches copy]];
        });
        
        if (self.isRegistered)
        {
            [self saveMatches:[newMatches copy]];
        }
    });
}

/**
 * @method loadMatches
 *
 * Calls appropriate methods to either load from 
 * core data or api call on a background queue.
 * These methods load the next 15 matches accordingly.
 * Then hands over data to delegate on main queue.
 */
- (void)loadMatches
{
    NSLog(@"[loadMatches]");
    dispatch_async(self.loadQueue,
    ^{
        //get matches according record in core data
        NSArray *matches = [self hasSavedMatches] ? [self loadFromLocal] : [self loadFromServer];
        
        //set oldest loaded match id, for next fetch
        self.oldestLoadedMatchId = [[matches lastObject][@"matchId"] longValue];
        
        //immediately give back to delegate
        dispatch_async(dispatch_get_main_queue(), ^{ [self.delegate didFinishLoadingMatches:matches]; });
        
        //if registered but not saved matches, fetch all matches ever
        if (self.isRegistered && ![self hasSavedMatches])
        {
            //15 because already loaded 0-14
            [self fetchAllMatches:matches Index:15];
        }
    });
}

- (void)fetchAllMatches:(NSArray *)matches Index:(int)index
{
    NSLog(@"fetch index: %d", index);
    if (matches.class != 0)
    {
        [self saveMatches:matches];
        
        dispatch_time_t secondDelay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(secondDelay, self.fetchQueue,
        ^{
            NSArray *matches = [self matchHistoryFrom:index To:index+15];
            [self fetchAllMatches:matches Index:index+15];
        });
    }
}

/**
 * @method loadFromLocal
 *
 * Loads the next 15 matches from Core Data.
 * By default fetches latest 15 matches,
 * but if lastLoadedIndex exists, loads the next 15.
 * @note Assumed that this method is called from background queue
 *       and that summoner is registered and set.
 *
 * @return NSArray of matches in reverse chronological
 */
- (NSArray *)loadFromLocal
{
    NSLog(@"[loadFromLocal]");
    
    //first fetch defaults to latest
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"summoner == %@", self.summoner];
    if (self.oldestLoadedMatchId != 0) //if not first fetch
    {
        predicate = [NSPredicate predicateWithFormat:@"summoner == %@ AND matchId < %@",
                                                        self.summoner,
                                                        [NSNumber numberWithLong:self.oldestLoadedMatchId]];
    }

    //set fetch
    NSFetchRequest *fetch      = [NSFetchRequest fetchRequestWithEntityName:@"Match"];
    NSSortDescriptor *descSort = [NSSortDescriptor sortDescriptorWithKey:@"matchId" ascending:NO];
    [fetch setFetchLimit:15];
    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:@[descSort]];
    
    NSError *error = nil;
    NSArray *matchEntities = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    
    //for every match from core data, convert to readable dictionary
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    for (Match *matchEntity in matchEntities)
    {
        NSMutableDictionary *match = [[NSMutableDictionary alloc] init];
        for (NSPropertyDescription *property in [NSEntityDescription entityForName:@"Match" inManagedObjectContext:self.managedObjectContext])
        {
            if (![property.name isEqual:@"summoner"])
            {
                [match setObject:[matchEntity valueForKey:property.name] forKey:property.name];
            }
        }
        [matches addObject:[match copy]];
    }
    
    return [matches copy];
}

/**
 * @method loadFromServer
 *
 * Calculates index range of the next 15 older matches.
 * Increments endMatchIndex accordingly,
 * and returns using - matchHistoryFrom:To:
 *
 * @return NSArray of matches in reverse chronological
 */
- (NSArray *)loadFromServer
{
    NSLog(@"[loadFromServer]");
    
    int begin = self.lastFetchIndex;
    self.lastFetchIndex += 15;
    return [self matchHistoryFrom:begin To:self.lastFetchIndex];
}

/**
 * @method matchHistoryFrom:To:
 *
 * Given an begin & end index query params,
 * fetchs that many matches from match history 
 * @note This method does not fetch from match api,
 *       which contains the specific data for all summoners
 */
- (NSArray *)matchHistoryFrom:(int)begin To:(int)end
{
    NSString *beginIndex = [NSString stringWithFormat:@"beginIndex=%d", begin];
    NSString *endIndex   = [NSString stringWithFormat:@"endIndex=%d", end];
    NSURL *url = apiURL(kLoLMatchHistory, self.summonerInfo[@"region"], [self.summonerInfo[@"id"] stringValue], @[beginIndex, endIndex]);
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [self.urlSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *matchHistory = [[dataDict[@"matches"] reverseObjectEnumerator] allObjects];
    
    long firstMatchId = [[matchHistory firstObject][@"matchId"] longValue];
    self.newestStoredMatchId = MAX(firstMatchId, self.newestStoredMatchId);

    return matchHistory;
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
    NSMutableArray *existingMatchIds = [[NSMutableArray alloc] init];
    for (Match *match in [[self.summoner matches] allObjects])
    {
        [existingMatchIds addObject:match.matchId];
    }

    //array of match data for every id
    for (NSDictionary *matchDict in matches)
    {
        // only add match if it is not already in the db
        if (![existingMatchIds containsObject:matchDict[@"matchId"]])
        {
            NSLog(@"new match id: %@", matchDict[@"matchId"]);
            //add to new entity
            Match *newMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Match"
                                                            inManagedObjectContext:self.managedObjectContext];
            newMatch.summoner = self.summoner;
            for (NSString *key in [matchDict allKeys])
            {
                [newMatch setValue:matchDict[key] forKey:key];
            }
            // Set up placeholder values
            // These will be set when the specific match is fetched
            newMatch.summonerIndex = @0;
            newMatch.matchCreation = @0;
            newMatch.teams = @[];
            [self.summoner addMatchesObject:newMatch];
        }
    }
    
    self.summoner.lastMatchId = matches[0][@"matchId"];
    [self saveContext];
}



#pragma mark - Core Data

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.raywenderlich.FailedBankCD" in the application's documents directory.
    //NSLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    //The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LemonNotes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LemonNotes.sqlite"];
    NSError *error = nil;
        // Handle db upgrade
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
                              NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES]};
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        //Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
