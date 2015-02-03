
#import "TAPManager.h"

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
@protocol TAPSummonerManagerDelegate

@optional
- (void)didFinishInitalLoadMatches:(int)numLoaded;
- (void)didFinishLoadingNewMatches:(int)numLoaded;
- (void)didFinishLoadingOldMatches:(int)numLoaded;

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
@interface TAPSummonerManager : TAPManager

@property (nonatomic, readonly) NSArray *loadedMatches;
@property (nonatomic, strong) NSDictionary *summonerInfo;
@property (nonatomic, weak) id<TAPSummonerManagerDelegate> delegate;

//account
- (instancetype)initWithSummoner:(NSDictionary *)summoner;
- (void)registerSummoner;
- (void)deregisterSummoner;

//matches
- (void)initalLoad;
- (void)loadNewMatches;
- (void)loadOldMatches;

//other
- (NSArray *)loadFromServer:(int)numberOfMatches;

@end
