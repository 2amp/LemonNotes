
#import <Foundation/Foundation.h>

/**
 * @class RiotDataManager
 * @brief Singleton manager to get LoL related data.
 *
 * 
 *
 * @note here is a note
 *
 * @author Bohui Moon, Chris Fu
 * @version 0.1
 */
@interface RiotDataManager : NSObject

+ (RiotDataManager *)sharedManager;

- (NSString *)championNameForId:(NSNumber *)championId;
- (NSString *)championKeyForId:(NSNumber *)championId;

@end
