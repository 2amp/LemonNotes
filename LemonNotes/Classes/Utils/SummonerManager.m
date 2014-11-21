
#import "NSURLSession+SynchronousTask.h"
#import "SummonerManager.h"
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
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic) long newestMatchId;
@property (nonatomic) long endMatchIndex;
- (void)saveMatches:(NSArray *)matches;
- (BOOL)hasSavedMatches;
- (NSArray *)loadFromLocal;
- (NSArray *)loadFromServer;
- (NSArray *)matchHistoryFrom:(long)begin To:(long)end;

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
        self.newestMatchId = self.isRegistered ? [self.summoner.lastMatchId longValue] : 0;
        self.endMatchIndex = 0;
        
        //make ephemeral session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        //create queue name "<summonerName> queue" for API calls
        const char *label = [[NSString stringWithFormat:@"%@ queue", summonerInfo[@"name"]] UTF8String];
        self.queue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
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


#pragma mark - Recent Matches
//get 15 of the latest matches from riot
//check if the latest match is newer than
- (void)refreshMatches
{
    dispatch_async(self.queue,
    ^{
        self.newestMatchId = 0; //temp while other things are set up
        
        //mutable array from fetched match history
        NSMutableArray *newMatches = [NSMutableArray arrayWithArray:[self matchHistoryFrom:0 To:15]];
        for (int i = (int)(newMatches.count-1); i >= 0; i--)
        {
            NSDictionary *match = [newMatches objectAtIndex:i];
            if ([match[@"matchId"] longValue] <= self.newestMatchId)
            {
                //remove any overlap matches with a match id equal/lower than current
                [newMatches removeObjectAtIndex:i];
            }
        }
        
        //increment endMatchId
        self.newestMatchId = [newMatches[0][@"matchId"] longValue];
        self.endMatchIndex += newMatches.count;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFinishRefreshingMatches:[newMatches copy]];
        });
        
        //if registered, save new matches
        //if (self.isRegistered)
        //    [self saveMatches:[newMatches copy]];
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
    dispatch_async(self.queue,
    ^{
        NSArray *matches = (self.isRegistered && [self hasSavedMatches]) ? [self loadFromServer] : [self loadFromServer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFinishLoadingMatches:matches];
        });
        
        //if (self.isRegistered && firstLoad)
        //    [self saveMatches:matches];
    });
}

/**
 * @method hasSavedMatches
 *
 * Checks whether registered summoner has stored mathces.
 * @note Assumed that summoner is registered and set.
 *
 * @return YES if summoner has stored matches.
 */
- (BOOL)hasSavedMatches
{
    return [self.summoner.matches count] > 0;
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
    //first fetch defaults to latest
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"summoner == %@", self.summoner];
    if (self.newestMatchId > 0) //if not first fetch
    {
        predicate = [NSPredicate predicateWithFormat:@"summoner == %@ AND matchId < %@", self.summoner, [NSNumber numberWithLong:self.newestMatchId]];
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
    
    //matches were loaded desc, so first is latest
    self.newestMatchId = [[matches lastObject][@"matchId"] longValue];
    
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
    long begin = self.endMatchIndex;
    self.endMatchIndex += 15;

    return [self matchHistoryFrom:begin To:self.endMatchIndex];
}

/**
 * @method matchHistoryFrom:To:
 *
 * Given an begin & end index query params,
 * fetchs that many matches from match history 
 * @note This method does not fetch from match api,
 *       which contains the specific data for all summoners
 */
- (NSArray *)matchHistoryFrom:(long)begin To:(long)end
{
    NSString *beginIndex = [NSString stringWithFormat:@"beginIndex=%ld", begin];
    NSString *endIndex   = [NSString stringWithFormat:@"endIndex=%ld", end];
    NSURL *url = apiURL(kLoLMatchHistory, self.summonerInfo[@"region"], [self.summonerInfo[@"id"] stringValue], @[beginIndex, endIndex]);
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [self.urlSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *matchHistory = [[dataDict[@"matches"] reverseObjectEnumerator] allObjects];

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
    //array of match data for every id
    for (NSDictionary *matchDict in matches)
    {
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
    
    self.summoner.lastMatchId = matches[0][@"matchId"];
    self.newestMatchId = [self.summoner.lastMatchId longValue];
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
    if (self.summoner == nil)
    {
        self.summoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner"
                                                      inManagedObjectContext:self.managedObjectContext];
        
        [self.summoner setValue:self.summonerInfo[@"region"] forKey:@"region"];
        [self.summoner setValue:self.summonerInfo[@"name"]   forKey:@"name"];
        [self.summoner setValue:self.summonerInfo[@"id"]     forKey:@"id"];
        [self.summoner setValue:@0 forKey:@"lastMatchId"];
        
        self.isRegistered = YES;
        //[self saveContext];
    }
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
    self.isRegistered = NO;
    self.summoner = nil;
    //[self saveContext];
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
