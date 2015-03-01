
#import <UIKit/UIKit.h>
#import "TAPManager.h"

/**
 * @class DataManager
 * @brief DataManager
 *
 * DataManager acts as a intermeidate class for
 * ViewControllers to fetch various LoL static data
 * so that every class does not implement its own data retrieval.
 * 
 * @note Currently only contains a dictionary of champion ID number to info mappings.
 *
 * @author Bohui Moon, Chris Fu
 * @version 0.1
 */
@interface TAPDataManager : TAPManager

+ (instancetype)sharedManager;

//static data
@property (nonatomic) NSArray *regions;
@property (nonatomic) NSDictionary *champions;
@property (nonatomic) NSDictionary *summonerSpells;
- (void)updateDataWithRegion:(NSString *)region completionHandler:(void (^)(NSError *))handler;

//accounts
- (void)printSummoners;
- (void)deleteAllSummoners;
- (void)getSummonerForName:(NSString *)name
                    region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler;

@end
