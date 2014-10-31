
#import <Foundation/Foundation.h>

/**
 * @class RiotDataManager
 * @brief Singleton manager to get LoL related data.
 *
 * Manages various static data so that it does not have to be passed among view
 * controllers.
 * Currently only contains a dictionary of champion ID number to info mappings.
 *
 * @author Bohui Moon, Chris Fu
 * @version 0.1
 */
@interface RiotDataManager : NSObject

+ (RiotDataManager *)sharedManager;

/**
 * Gets the name of the champion with the given ID.
 *
 * @param championId
 */
- (NSString *)championNameForId:(NSNumber *)championId;

/**
 * Gets the key of the champion with the given ID. The key is used as the file
 * name of the champion icon image.
 *
 * @param championId
 */
- (NSString *)championKeyForId:(NSNumber *)championId;

@end
