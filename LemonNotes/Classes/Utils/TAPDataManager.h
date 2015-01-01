
#import <UIKit/UIKit.h>
#import "TAPManager.h"
#import "Summoner.h"



@protocol TAPDataManagerDelegate

@optional
- (void)didFinishLoadingData;

@end

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
+ (void)getSummonerForName:(NSString *)name
                    region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler;

//accounts
- (void)summonerDump;
- (void)registerSummoner;
- (void)deleteAllSummoners;

//recent games
@property (nonatomic) NSArray *recentMatches;
- (void)loadRecentMatches;
- (NSNumber *)saveRecentMatchesForSummoner:(Summoner *)summoner;

// delegate
@property (nonatomic, weak) id<TAPDataManagerDelegate> delegate;

//static data
@property (nonatomic) NSArray *regions;
@property (nonatomic) NSDictionary *champions;
@property (nonatomic) NSDictionary *summonerSpells;
- (void)updateChampionIds;
- (void)updateSummonerSpells;
- (void)updateAllData;

@end
