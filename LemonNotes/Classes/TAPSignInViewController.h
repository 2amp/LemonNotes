
#import <UIKit/UIKit.h>

/**
 * Class: TAPSignInViewController
 * Type: view controller
 * --------------------------
 * Initial view controller presented to the user. Contains a text field for the
 * user to enter summonerName and sign in.
 */
@interface TAPSignInViewController : UIViewController
            <NSURLSessionTaskDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *summonerId;
@property (nonatomic) NSArray *recentGames;

@property (weak, nonatomic) IBOutlet UITextField *signInField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)signIn;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

