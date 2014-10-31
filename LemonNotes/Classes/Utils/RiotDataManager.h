
#import <Foundation/Foundation.h>



/**
 * Class: RiotDataManager
 * Type: singleton manager
 * --------------------------
 *
 */
@interface RiotDataManager : NSObject

+ (RiotDataManager *)sharedManager;

- (NSString *)championNameForId:(NSNumber *)championId;
- (NSString *)championKeyForId:(NSNumber *)championId;

@end
