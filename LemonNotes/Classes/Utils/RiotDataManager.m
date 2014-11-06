
#import "RiotDataManager.h"
#import "Constants.h"



@interface RiotDataManager()

//Core Data
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)saveContext;

//URL
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary *championIds;
@property (nonatomic) NSDictionary *summonerSpells;

//Private util methods
- (BOOL)version:(NSString *)newVersion isHigherThan:(NSString *)currentVersion;
- (NSNumber *)latestGameIdForSummoner:(NSNumber *)summonerId;
- (NSManagedObject *)isRegisteredSummoner:(NSNumber *)summonerId;

@end



@implementation RiotDataManager

#pragma mark - Init Methods
/**
 * @method sharedManager
 *
 * Returns a singleton of RiotDataManager
 * using a threadsafe GCD initialization.
 *
 * @return RiotDataManager instance
 */
+ (RiotDataManager *)sharedManager
{
    static RiotDataManager *sharedManager = nil;
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
        self.urlSession = [NSURLSession sharedSession];
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
    
    for (int i=0; i<newVersionParts.count; i++)
    {
        int newVal = [newVersionParts[i] intValue];
        int oldVal = [oldVersionParts[i] intValue];
        
        if (newVal < oldVal) return NO;
        if (newVal > oldVal) return YES;
    }
    
    return NO;
}

/**
 * @method fetchSummoner
 *
 * Returns
 *
 * @return NSManagedObject of requested summoner
 */
- (NSManagedObject *)fetchSummoner:(NSNumber *)summonerId
{
    NSFetchRequest      *summonerFetch  = [[NSFetchRequest alloc] init];
    NSEntityDescription *summonerEntity = [NSEntityDescription entityForName:@"summoner" inManagedObjectContext:self.managedObjectContext];
    NSPredicate         *idPredicate    = [NSPredicate predicateWithFormat: @"summonerId == %@", summonerId];
    [summonerFetch setEntity:summonerEntity];
    [summonerFetch setPredicate:idPredicate];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    
    //summoner found
    if ([result count] == 0)
    {
        NSManagedObject *newSummoner = [NSEntityDescription insertNewObjectForEntityForName:@"Summoner"
                                                                        inManagedObjectContext:self.managedObjectContext];
        
    }
    return result[0];
}

- (NSNumber *)latestGameIdForSummoner:(NSNumber *)summonerId
{
    NSFetchRequest      *gamesFetch  = [[NSFetchRequest alloc] init];
    NSEntityDescription *gamesEntity = [NSEntityDescription entityForName:@"Game" inManagedObjectContext:self.managedObjectContext];
    NSPredicate         *summonerObj = [NSPredicate predicateWithFormat:@"summoner == %@", [self fetchSummoner:summonerId]];
    NSSortDescriptor    *gameIdSort  = [[NSSortDescriptor alloc] initWithKey:@"gameId" ascending:NO];
    [gamesFetch setEntity:gamesEntity];
    [gamesFetch setPredicate:summonerObj];
    [gamesFetch setSortDescriptors:@[gameIdSort]];
    
    NSError *error = nil;
    NSArray *games = [self.managedObjectContext executeFetchRequest:gamesFetch error:&error];
    if (error)
    {
        NSLog(@"Error while fetching games: %@", error);
        return @(-1);
    }
    if ([games count] < 1)
    {
        return @0;
    }
    return [games[0] valueForKey:@"gameId"];
}


#pragma mark - Champion Static Data Methods
- (void)recordGames:(NSArray *)games forSummoner:(NSNumber *)summonerId
{
    NSNumber *latestGameId = [self latestGameIdForSummoner:summonerId];
    for (NSDictionary *game in games)
    {
        if (game[@"gameId"] > latestGameId)
        {
            
        }
    }
}

/**
 * Updates the championIds dictionary by calling Riot API.
 * @note Currently uses NSURLSession, but should call 
 *       some sort of NetworkManager to take care of networking.
 */
- (void)updateChampionIds
{
    /// maps champion names to ids
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            NSDictionary* championIdsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSMutableDictionary *championIds = [NSMutableDictionary dictionaryWithDictionary:[championIdsDict objectForKey:@"data"]];
            NSArray *keys = [championIds allKeys];
            for (NSString *key in keys)
            {
                NSDictionary *info = [championIds objectForKey:key];
                [championIds removeObjectForKey:key];
                [championIds setObject:info forKey:[info objectForKey:@"id"]];
            }
            self.championIds = [NSDictionary dictionaryWithDictionary:championIds];
        }
        else
        {
            NSLog(@"Champion list API call error: %@", error);
        }
    };
    
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:apiURL(kLoLStaticDataChampionList, @"na", nil)
                                                    completionHandler:completionHandler];
    [dataTask resume];
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
            NSError* jsonParsingError = nil;
            NSDictionary* summonerSpellsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError)
            {
                NSLog(@"%@", jsonParsingError);
            }
            else
            {
                NSMutableDictionary *summonerSpells = [NSMutableDictionary dictionaryWithDictionary:[summonerSpellsDict objectForKey:@"data"]];
                NSArray *keys = [summonerSpells allKeys];
                for (NSString *key in keys)
                {
                    NSDictionary *info = [summonerSpells objectForKey:key];
                    [summonerSpells removeObjectForKey:key];
                    [summonerSpells setObject:info forKey:[info objectForKey:@"id"]];
                }
                self.summonerSpells = [NSDictionary dictionaryWithDictionary:summonerSpells];
            }
        }
        else
        {
            NSLog(@"There was an error with the champion API call!");
        }
    };
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:apiURL(kLoLStaticDataSpellList, @"na", nil)
                                                    completionHandler:completionHandler];
    [dataTask resume];

}

/**
 * @method championNameForId:
 *
 * Gets the name of the champion with the given ID.
 *
 * @param championId id number of champion
 * @return NSString* champion key
 */
- (NSString *)championNameForId:(NSNumber *)championId
{
    return self.championIds[championId][@"name"];
}

/**
 * @method championKeyForId
 *
 * Gets the key of the champion with the given ID. 
 * The key is used as the file name of the champion icon image.
 *
 * @param championId id number of champion
 * @return NSString* champion key
 */
- (NSString *)championKeyForId:(NSNumber *)championId
{
    return self.championIds[championId][@"key"];
}

- (NSString *)summonerSpellKeyForId:(NSNumber *)spellId
{
    return self.summonerSpells[spellId][@"key"];
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
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
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
