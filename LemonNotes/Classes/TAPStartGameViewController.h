
#import <UIKit/UIKit.h>

/**
 * @class TAPStartGameViewController
 * @brief TAPStartGameViewController
 *
 * After the user has signed in, asks the user for information about the current
 * game such as the player's side, whether or not the player is the team
 * captain, and who his teammates are.
 *
 * summonerName and idNumber are passed in by the sign in view controller before
 * the segue.
 * 
 * @author Chris Fu
 * @version 0.1
 */
@interface TAPStartGameViewController : UIViewController

@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *idNumber;

@property (weak, nonatomic) IBOutlet UILabel *summonerNameLabel;

@end
