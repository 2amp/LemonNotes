
#import "RiotDataManager.h"
#import "Constants.h"



@interface RiotDataManager()

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary *championIds;
@property (nonatomic) NSDictionary *summonerSpells;

- (BOOL)version:(NSString *)newVersion isHigherThan:(NSString *)currentVersion;

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



#pragma mark - Champion Static Data Methods
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
            NSLog(@"There was an error with the champion API call!");
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

@end
