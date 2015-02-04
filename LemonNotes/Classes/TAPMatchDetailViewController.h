
#import <UIKit/UIKit.h>

/**
 * @class TAPMatchDetailViewController
 * @brief TAPMatchDetailViewController
 *
 * ViewController to present details of a certain match.
 * Invoked when user taps on a cell in MatchHistoryVC
 */
@interface TAPMatchDetailViewController : UIViewController
            <UITableViewDelegate, UITableViewDataSource>

//public properties
@property (nonatomic, strong) NSNumber *matchId;
@property (nonatomic, strong) NSDictionary *summonerInfo;

@end
