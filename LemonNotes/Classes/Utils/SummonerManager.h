
#import "Manager.h"

/**
 * @protocol SummonerManagerDelegate
 * @brief    SummonerManagerDelegate
 *
 * SummonerManager calls various methods 
 * as defined by SummonerManagerDelegate.
 *
 * Becase many of the recent matches fetching
 * must be done asynchronously, 
 * fetched data is given through delegate methods.
 */
@protocol SummonerManagerDelegate

//data from refresh should be added to the front
//data from loading should be added to the back
@optional
- (void)didFinishRefreshingMatches:(NSArray *)matches;
- (void)didFinishLoadingMatches:(NSArray *)matches;

@end


/**
 * @class SummonerManager
 * @brief SummonerManager
 * 
 * Summoner manager controls one summoner.
 * It can add/delete summoners through core data.
 *
 * This manager mainly focuses on summoner's
 * summary & recent matches and should be provided
 * basic info regarding summoner id & name.
 *
 * All fetch of recent matches is done async
 * and will call appropriate delegate upon completion.
 * It will be up to delegate to implement UI on main queue.
 */
@interface SummonerManager : Manager

- (instancetype)initWithSummoner:(NSDictionary *)summoner;

//delegate
@property (nonatomic, weak) id<SummonerManagerDelegate> delegate;

//account
- (void)registerSummoner;
- (void)deregisterSummoner;

//recent matches
- (void)refreshMatches;
- (void)loadMatches;
- (NSArray *)loadFromServer;

@end