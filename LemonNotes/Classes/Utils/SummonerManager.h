
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


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

/**
 * @method didFinishRefreshingMatches
 *
 * Called when match history is refreshed,
 * checking for any new matches not show.
 * These should be prepended to the front.
 */
- (void)didFinishRefreshingMatches:(NSArray *)matches;

/**
 * @method didFinishLoadingMatches
 *
 * Called when next set of matches are loaded.
 * These should always be appened to the back.
 */
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
@interface SummonerManager : NSObject

//delegate
@property (nonatomic, weak) id<SummonerManagerDelegate> delegate;
@property (nonatomic, strong) NSArray *loadedMatches;

//recent matches
- (void)refreshMatches;
- (void)loadMatches;

//account
- (void)registerSummoner;
- (void)deregisterSummoner;

@end
