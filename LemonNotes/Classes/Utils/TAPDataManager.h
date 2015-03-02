
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
 * @author Bohui Moon
 * @version 0.1
 */
@interface TAPDataManager : TAPManager

+ (instancetype)sharedManager;
- (void)loadData;
- (void)saveData;

//static data
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) NSDictionary *realms;
@property (nonatomic, strong) NSDictionary *champList;
@property (nonatomic, strong) NSDictionary *spellList;
- (void)updateDataWithRegion:(NSString *)region completionHandler:(void (^)(NSError *))handler;

//images
- (void)setItemIconWithKey:(NSString *)key toView:(UIImageView *)view;
- (void)setSpellIconWithKey:(NSString *)key toView:(UIImageView *)view;
- (void)setChampIconWithKey:(NSString *)key toView:(UIImageView *)view;
- (void)setChampSplashWithKey:(NSString *)key toView:(UIImageView *)view;
- (void)setProfileIconWithKey:(NSString *)key toView:(UIImageView *)view;

//accounts
- (void)printSummoners;
- (void)deleteAllSummoners;
- (void)getSummonerForName:(NSString *)name
                    region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler;

@end
