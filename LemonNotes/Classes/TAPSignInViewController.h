
#import <UIKit/UIKit.h>

/**
 * @class TAPSignInViewController
 * @brief TAPSignInViewController
 *
 * Initial view controller presented to the user. 
 * Contains a text field for the user to enter summonerName, and a nice logo.
 *
 * @note SignInVC is currently the first screen, but should be changed to MainVC
 *
 * @author Chris Fu, Bohui Moon
 * @version 0.1
 */
@interface TAPSignInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *summonerId;
@property (nonatomic) NSArray *recentGames;

@property (weak, nonatomic) IBOutlet UITextField *signInField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)signIn;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

