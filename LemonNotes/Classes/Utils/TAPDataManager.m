
#import "TAPDataManager.h"
#import "Constants.h"
#import "NSURLSession+SynchronousTask.h"
#import "Match.h"



@interface TAPDataManager()

//session
@property (nonatomic, strong) NSURLSession *urlSession;

//Private util methods
- (BOOL)version:(NSString *)newVersion isHigherThan:(NSString *)currentVersion;
- (Summoner *)currentSummonerEntity;

@end
#pragma mark -


@implementation TAPDataManager

#pragma mark Init Methods
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
    static TAPDataManager *sharedManager = nil;
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


/**
 * @method getSummonerForName:Region:successHandler:failureHandler
 *
 * Given a summoner's name and region, attempts to fetch the summoner from Riot API.
 * If the statusCode is successful, the received data is assumed to be valid JSON and
 * converted to NSDictionary with with region included.
 * Otherwise a error message is created.
 * The callbacks are called accordingly back on the main thread.
 *
 * @param name           - name of summoner to search
 * @param region         - region to search summoner in
 * @param successHandler - code block to be called upon successful fetch
 * @param failureHandler - code block to be called upon failed fetch
 */
+ (void)getSummonerForName:(NSString *)name
                    region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler
{
    NSURL *url = apiURL(kLoLSummonerByName, region, name, @[]);
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) //successful
        {
            //retrieve and set region
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSMutableDictionary *summonerInfo = [NSMutableDictionary dictionaryWithDictionary:dataDict[[dataDict allKeys][0]]];
            [summonerInfo setObject:region forKey:@"region"];

            //callback on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler([summonerInfo copy]);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //call failureHandler with error message
                NSString *errorMessage = [NSString stringWithFormat:@"Error %d: %@",
                                          (int)httpResponse.statusCode,
                                          [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                failureHandler(errorMessage);
            });
        }
    }] resume];
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
        NSLog(@"currentSummonerEntity %@", summonerInfo);
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



#pragma mark - Summoner Accounts
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
    
    NSLog(@"Summoners in CoreData:");
    for (Summoner *summoner in result)
    {
        NSLog(@"%@ (region: %@)", summoner.name, summoner.region);
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

/**
 * @method registerSummoner
 *
 * Enters the summoner as a new entity into core data.
 * Saves all ranked games.
 *
 * @note currently only saves last 15 games,
 *       but should save all games in the future.
 */
- (void)registerSummoner
{
    Summoner *summoner = [self currentSummonerEntity];
    NSNumber *lastMatchId = [self saveRecentMatchesForSummoner:summoner];
    [summoner setValue:lastMatchId forKey:@"lastMatchId"];
    [self saveContext];
}

#pragma mark - Recent Matches
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
 * @method saveMatchHistoryForSummoner:
 * 
 * Given an summoner coredata entity,
 * fetches the 15 most recent matches and adds them. Does not initialize all
 * match fields since matchhistory doesn't provide some of them. We defer the
 * initialization of those fields until when the actual match itself needs to be
 * fetched (such as when the game in the summoner vc is tapped).
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
    NSURL *url = apiURL(kLoLMatchHistory, summonerInfo[@"region"], [summonerInfo[@"id"] stringValue], @[@"endIndex=15"]);
    NSData *matchHistoryData = [self.urlSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];

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
    //NSLog(@"%@", existingMatchIds);

    //array of match data for every id
    for (NSDictionary *matchDict in matches)
    {
        // only add match if it is not already in the db
        if (![existingMatchIds containsObject:matchDict[@"matchId"]])
        {
            //add to new entity
            Match *newMatch = [NSEntityDescription insertNewObjectForEntityForName:@"Match"
                                                            inManagedObjectContext:self.managedObjectContext];
            newMatch.summoner = summoner;
            for (NSString *key in [matchDict allKeys])
            {
                [newMatch setValue:matchDict[key] forKey:key];
            }
            // Set up placeholder values
            // These will be set when the specific match is fetched
            newMatch.summonerIndex = @0;
            newMatch.matchCreation = @0;
            newMatch.teams = @[];
            [summoner addMatchesObject:newMatch];
        }
    }

    //return latest match id
    if (matchIds.count == 0)
    {
        return @0;
    }
    else
    {
        return matchIds[0];
    }
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

- (void)updateAllData
{
    void (^summonerSpellCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            self.summonerSpells = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"data"];
        }
        else
        {
            NSLog(@"There was an error with the champion API call!");
        }
        [self.delegate didFinishLoadingData];
    };

    void (^championIdCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            self.champions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"data"];
            [[self.urlSession dataTaskWithURL:apiURL(kLoLStaticSpellList, @"na", @"", @[@"dataById=true"])
                            completionHandler:summonerSpellCompletionHandler]
             resume];
        }
        else
        {
            NSLog(@"Champion list API call error: %@", error);
        }

    };

    [[self.urlSession dataTaskWithURL:apiURL(kLoLStaticChampionList, @"na", @"", @[@"dataById=true"])
                    completionHandler:championIdCompletionHandler]
     resume];
}

@end