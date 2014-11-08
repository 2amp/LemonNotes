
#import "DataManager.h"
#import "Constants.h"
#import "NSURLSession+SynchronousTask.h"
#import "Summoner.h"
#import "Match.h"



@interface DataManager()

//Core Data
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)saveContext;

//session
@property (nonatomic, strong) NSURLSession *urlSession;

//Private util methods
- (BOOL)version:(NSString *)newVersion isHigherThan:(NSString *)currentVersion;
- (Summoner *)currentSummonerEntity;

@end



@implementation DataManager

#pragma mark - Init Methods
/**
 * @method sharedManager
 *
 * Returns a singleton of DataManager
 * using a threadsafe GCD initialization.
 *
 * @return DataManager instance
 */
+ (instancetype)sharedManager
{
    static DataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 * @method init
 *
 * Initializes an NSURLSession instance for data requests.
 * Performs a champion ID data request to populate self.championIds with a 
 * dictionary mapping each champion ID to the name of the champion.
 */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        self.regions = @[@"br", @"eune", @"euw", @"kr", @"lan", @"las", @"na", @"oce", @"ru", @"tr"];
    }
    return self;
}



#pragma mark - Private Util Mehtods
/**
 * @method version:isHigherThan:
 * 
 * Takes a version string and determines if 
 * the former is later than the latter.
 *
 * @note The two version strings must be of the same format
 *       ex) "1.0.4" & "1.0.3"
 *
 * @param newVersion - NSString* of newly received version
 * @param oldVersion - NSString* of stored version
 * @return YES if newVersion is higher than oldVersion
 */
- (BOOL)version:(NSString *)newVersion isHigherThan:(NSString *)oldVersion
{
    NSArray *newVersionParts = [newVersion componentsSeparatedByString:@"."];
    NSArray *oldVersionParts = [oldVersion componentsSeparatedByString:@"."];
    
    for (int i = 0; i < newVersionParts.count; i++)
    {
        int newVal = [newVersionParts[i] intValue];
        int oldVal = [oldVersionParts[i] intValue];
        
        if (newVal < oldVal) return NO;
        if (newVal > oldVal) return YES;
    }
    
    return NO;
}

/**
 * @method currentSummonerEntity
 *
 * Returns the summoner entity corresponding to the summoner set in NSUserDefaults.
 * If the summoner entity does not exists, it creates a new one.
 *
 * @return Summoner entity of current summoner
 */
- (Summoner *)currentSummonerEntity
{
    // get summonerId
    NSDictionary *summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    
    // fetch for summoner entity with summonerId
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    [summonerFetch setPredicate:[NSPredicate predicateWithFormat:@"id == %@", summonerInfo[@"id"]]];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    
    // if no result, create and recursively return
    if ([result count] == 0)
    {
        Summoner *newSummoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner"
                                                              inManagedObjectContext:self.managedObjectContext];
        
        [newSummoner setValue:summonerInfo[@"region"] forKey:@"region"];
        [newSummoner setValue:summonerInfo[@"name"]   forKey:@"name"];
        [newSummoner setValue:summonerInfo[@"id"]     forKey:@"id"];
        return newSummoner;
    }
    
    // ensured there is one & only 1 summoner entity with summonerId
    return result[0];
}

/**
 * @method summonnerDump
 *
 * Dumps all the summoners in core data into NSLog
 * @note method to be removed some time
 */
- (void)summonerDump
{
    // fetch for summoner entity with summonerId
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];

    for (Summoner *summoner in result)
    {
        NSLog(@"%@", summoner);
    }
}

/**
 * @method deleteAllSummoners
 *
 * Deletes all summoners in core data
 */
- (void)deleteAllSummoners
{
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];

    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    for (Summoner *summoner in result)
    {
        [self.managedObjectContext deleteObject:summoner];
    }
    [self saveContext];
    NSLog(@"%lul", [self.managedObjectContext executeFetchRequest:summonerFetch error:&error].count);
}



#pragma mark - Public Summoner Data Methods
/**
 * @loadRecentMatches
 *
 * Loads from core data the currently selected summoner's recent matches
 * into a public array that can be accessed by any view controller.
 */
- (void)loadRecentMatches
{
    //get the current summoner's entity
    Summoner *summoner = [self currentSummonerEntity];

    //make a fetch with the summoner, ordered latest match first
    NSFetchRequest *fetch           = [NSFetchRequest fetchRequestWithEntityName:@"Match"];
    NSPredicate *summonerPredicate  = [NSPredicate predicateWithFormat:@"summoner == %@", summoner];
    NSSortDescriptor *matchIdSort   = [NSSortDescriptor sortDescriptorWithKey:@"matchId" ascending:NO];
    [fetch setPredicate:summonerPredicate];
    [fetch setSortDescriptors:@[matchIdSort]];
    
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
    self.recentMatches = [matches copy];
}

/**
 * @method registerSummoner
 *
 * Enters the summoner as a new entity into core data.
 * Saves all ranked games.
 *
 * @note currently only saves last 10 games,
 *       but should save all games in the future.
 */
- (void)registerSummoner
{
    Summoner *summoner = [self currentSummonerEntity];
    NSNumber *lastMatchId = [self saveRecentMatchesForSummoner:summoner];
    [summoner setValue:lastMatchId forKey:@"lastMatchId"];
    [self saveContext];
}

/**
 * @method saveMatchHistoryForSummoner:
 * 
 * Given an summoner coredata entity,
 * fetches the recent 10 matches and adds them.
 *
 * @note in the future, this method should check and add matches
 *       up until the stored lastMatchId for summoner (this could be all ranked games)
 *
 * @param summoner NSManagedObject of summoner to update match history
 * @return NSNumber of last matchId
 */
- (NSNumber *)saveRecentMatchesForSummoner:(Summoner *)summoner
{
    NSDictionary *summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    
    //get match history
    NSError *error;
    NSHTTPURLResponse *response;
    NSURL *url = apiURL(kLoLMatchHistory, summonerInfo[@"region"], [summonerInfo[@"id"] stringValue], @[@"beginIndex=0", @"endIndex=5"]);
    NSData *matchHistoryData = [NSURLSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    
    //make array of match ids
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:matchHistoryData options:kNilOptions error:nil];
    NSArray *matches = [[dataDict[@"matches"] reverseObjectEnumerator] allObjects];
    NSMutableArray *matchIds = [[NSMutableArray alloc] init];
    for (NSDictionary *match in matches)
    {
        [matchIds addObject:match[@"matchId"]];
    }

    // get existing match ids
    NSMutableArray *existingMatchIds = [[NSMutableArray alloc] init];
    for (Match *match in [[summoner matches] allObjects])
    {
        [existingMatchIds addObject:match.matchId];
    }
    NSLog(@"%@", existingMatchIds);
    
    //array of match data for every id
    for (NSNumber *matchId in matchIds)
    {
        // only add match if it is not already in the db
        if (![existingMatchIds containsObject:matchId])
        {
            //fetch match data
            url = apiURL(kLoLMatch, summonerInfo[@"region"], [matchId stringValue], nil);
            NSData *matchData = [NSURLSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
            NSDictionary *matchDict = [NSJSONSerialization JSONObjectWithData:matchData options:kNilOptions error:nil];

            //add to new entity
            Match *newMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Match"
                                                            inManagedObjectContext:self.managedObjectContext];
            newMatch.summoner = summoner;
            for (NSString *key in [matchDict allKeys])
            {
                [newMatch setValue:matchDict[key] forKey:key];
            }

            //find and set which participantId summoner is
            for (NSDictionary *participant in matchDict[@"participantIdentities"])
            {
                if (participant[@"player"][@"summonerId"] == summonerInfo[@"id"])
                {
                    int index = [participant[@"participantId"] intValue] - 1;
                    newMatch.summonerIndex = [NSNumber numberWithInt:index];
                }
            }

            //add to summoner's matches
            //        [[summoner valueForKey:@"matches"] addObject:newMatch];
            [summoner addMatchesObject:newMatch];
        }
    }
    
    //return latest match id
    return matchIds[0];
}



#pragma mark - Champion Static Data Methods
/**
 * @method updateChampionIds
 *
 * Updates the championIds dictionary by calling Riot API.
 *
 * @note the keys are string values, not NSNumbers
 */
- (void)updateChampionIds
{
    /// maps champion names to ids
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            self.champions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"data"];
        }
        else
        {
            NSLog(@"Champion list API call error: %@", error);
        }
    };
    
    [[self.urlSession dataTaskWithURL:apiURL(kLoLStaticChampionList, @"na", @"", @[@"dataById=true"]) completionHandler:completionHandler]
     resume];
}

/**
 * Updates the summoner spell dictionary by calling Riot API.
 */
- (void)updateSummonerSpells
{
    /// maps summoner spell ids to names
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            self.summonerSpells = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"data"];
        }
        else
        {
            NSLog(@"There was an error with the champion API call!");
        }
    };
    
    [[self.urlSession dataTaskWithURL:apiURL(kLoLStaticSpellList, @"na", @"", @[@"dataById=true"]) completionHandler:completionHandler]
     resume];

}



#pragma mark - Core Data stack

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.raywenderlich.FailedBankCD" in the application's documents directory.
    NSLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
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

- (NSManagedObjectContext *)managedObjectContext {
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

#pragma mark - Core Data Saving support

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
