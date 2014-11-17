
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Summoner.h"

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
@interface DataManager : NSObject

+ (instancetype)sharedManager;

//accounts
- (void)summonerDump;
- (void)registerSummoner;
- (void)deleteAllSummoners;

//recent games
@property (nonatomic) NSArray *recentMatches;
- (void)loadRecentMatches;
- (NSNumber *)saveRecentMatchesForSummoner:(Summoner *)summoner;

//static data
@property (nonatomic) NSArray *regions;
@property (nonatomic) NSDictionary *champions;
@property (nonatomic) NSDictionary *summonerSpells;
- (void)updateChampionIds;
- (void)updateSummonerSpells;

//core data
- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end
