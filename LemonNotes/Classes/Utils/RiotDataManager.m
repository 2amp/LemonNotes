
#import "RiotDataManager.h"
#import "Constants.h"
#import <sqlite3.h>

@interface RiotDataManager()

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary *championIds;

@end


#pragma mark -
@implementation RiotDataManager

#pragma mark Synthesize Properties


#pragma mark - Setup Methods
/**
 * Func: sharedManager
 * Usage: to call singleton of RiotDataManager
 * --------------------------
 * Uses thread safe method to create (if not already created)
 * and return singleton of RiotDataManager
 *
 * @return RiotDataManager* singleton
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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        //maps champion names to ids
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.urlSession = [NSURLSession sessionWithConfiguration:config];
        
        void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (!error)
            {
                NSError* jsonParsingError = nil;
                NSDictionary* championIdsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                if (jsonParsingError)
                {
                    NSLog(@"%@", jsonParsingError);
                }
                else
                {
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
    return self;
}

- (NSString *)championNameForId:(NSNumber *)championId
{
    return self.championIds[championId][@"name"];
}

- (NSString *)championKeyForId:(NSNumber *)championId
{
    return self.championIds[championId][@"key"];
}

@end

















