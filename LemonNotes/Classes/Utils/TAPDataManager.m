
#import "NSURLSession+SynchronousTask.h"
#import "TAPDataManager.h"
#import "TAPUtil.h"
#import "Summoner.h"
#import "Match.h"


@interface TAPDataManager()
{
    dispatch_queue_t fetchQueue;
}

//session
@property (nonatomic, strong) NSURLSession *urlSession;

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
        fetchQueue = dispatch_queue_create("TAPDataManager Data Fetch Queue", DISPATCH_QUEUE_CONCURRENT);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        self.regions = @[@"br", @"eune", @"euw", @"kr", @"lan", @"las", @"na", @"oce", @"ru", @"tr"];
    }
    return self;
}

#pragma mark - Static Data
/**
 * @method updateDataWithRegion:completionHandler
 *
 * Given a region and a callback handler,
 * fetchs list of champions and summoner spells async.
 * If there is an error, existing dictionaries are untouched.
 * Calls handler back on main queue on completion.
 */
- (void)updateDataWithRegion:(NSString *)region completionHandler:(void (^)(NSError *))handler
{
    dispatch_async(fetchQueue,
    ^{
        //champion list
        NSError *champError = nil;
        NSHTTPURLResponse *champResponse = nil;
        NSURL *champListURL = apiURL(kLoLStaticChampionList, region, @"", @[@"dataById=true"]);
        NSData *champListData = [self.urlSession sendSynchronousDataTaskWithURL:champListURL
                                                             returningResponse:&champResponse
                                                                         error:&champError];
       
        //spells list
        NSError *spellError = nil;
        NSHTTPURLResponse *spellResponse = nil;
        NSURL *spellListURL = apiURL(kLoLStaticSpellList, region, @"", @[@"dataById=true"]);
        NSData *spellListData = [self.urlSession sendSynchronousDataTaskWithURL:spellListURL
                                                             returningResponse:&spellResponse
                                                                         error:&spellError];
       
        if (!champError)
            self.champions = [NSJSONSerialization JSONObjectWithData:champListData options:kNilOptions error:nil][@"data"];
        if (!spellError)
            self.summonerSpells = [NSJSONSerialization JSONObjectWithData:spellListData options:kNilOptions error:nil][@"data"];
       
        //callback
        NSError *error = nil;
        if (champError || spellError)
            error = [NSError errorWithDomain:@"Riot LoL API Static Data Fetch Error" code:500 userInfo:nil];
       
        dispatch_async(dispatch_get_main_queue(), ^{ handler(error); });
    });
}


#pragma mark - Summoner Accounts
/**
 * @method summonnerDump
 *
 * Dumps all the summoners in core data into NSLog
 * @note method to be removed some time
 */
- (void)printSummoners
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
        for (Match* match in summoner.matches)
            [self.managedObjectContext deleteObject:match];
        
        [self.managedObjectContext deleteObject:summoner];
    }
    [self saveContext];
    NSLog(@"%lul", [self.managedObjectContext executeFetchRequest:summonerFetch error:&error].count);
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
- (void)getSummonerForName:(NSString *)name region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler
{
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:apiURL(kLoLSummonerByName, region, name, @[])
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) //successful
        {
            //retrieve and set region
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSMutableDictionary *summonerInfo = [NSMutableDictionary dictionaryWithDictionary:dataDict[[dataDict allKeys][0]]];
            [summonerInfo setObject:region forKey:@"region"];
          
            //callback on main thread
            dispatch_async(dispatch_get_main_queue(), ^{ successHandler([summonerInfo copy]); });
        }
        else
        {
            NSString *errorMessage = [NSString stringWithFormat:@"Error %d: %@", (int)httpResponse.statusCode,
                                      [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
            dispatch_async(dispatch_get_main_queue(), ^{ failureHandler(errorMessage); });
        }
    }];
    
    [task resume];
}


@end
