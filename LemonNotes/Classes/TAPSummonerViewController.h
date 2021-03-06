
#import <UIKit/UIKit.h>
#import "TAPSummonerManager.h"

/**
 * @class TAPMainViewController
 * @brief TAPMainViewController
 *
 * TAPMainViewController is the main screen of the app.
 * It displays the default users base info and 
 * provides an UI to connect to other ViewControllers.
 *
 * Upon app start, if there is no default user registered in UserDefaults,
 * redirects to TAPSignInViewController for enter a summonerName.
 *
 * @author Bohui Moon, Chris Fu
 * @version 0.1
 */
@interface TAPSummonerViewController : UIViewController
<TAPSummonerManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *summonerInfo;

@end