
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/**
 * @class RiotDataManager
 * @brief RiotDataManager
 *
 * RiotDataManager acts as a intermeidate class for
 * ViewControllers to fetch various LoL static data
 * so that every class does not implement its own data retrieval.
 * 
 * @note Currently only contains a dictionary of champion ID number to info mappings.
 *
 * @author Bohui Moon, Chris Fu
 * @version 0.1
 */
@interface RiotDataManager : NSObject

+ (RiotDataManager *)sharedManager;

@property (nonatomic) NSDictionary *champions;
@property (nonatomic) NSDictionary *summonerSpells;


//static data
- (void)updateChampionIds;
- (void)updateSummonerSpells;

@end
