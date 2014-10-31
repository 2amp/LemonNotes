
#import <UIKit/UIKit.h>

/**
 * @class TAPMatchHistoryTableViewController
 * @brief TAPMatchHistoryTableViewController
 *
 * Displays a table view of recent matches played by the summoner. Matches are 
 * fetched using the matchhistory endpoint (see Constants.h). 
 * 
 * @note Currently only ranked matches are displayed, most recent first.
 *
 * @author Chris Fu
 * @version 0.1
 */
@interface TAPMatchHistoryTableViewController : UIViewController

@property (nonatomic) NSArray *recentGames;

@end
