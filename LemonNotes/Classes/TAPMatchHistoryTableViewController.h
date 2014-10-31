
#import <UIKit/UIKit.h>

/**
 * Displays a table view of recent matches played by the summoner. Matches are 
 * fetched using the matchhistory endpoint (see Constants.h). Currently only
 * ranked matches are displayed, most recent first.
 */
@interface TAPMatchHistoryTableViewController : UIViewController

@property (nonatomic) NSArray *recentGames;

@end
