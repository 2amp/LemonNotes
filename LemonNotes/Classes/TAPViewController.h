
#import <UIKit/UIKit.h>

/**
 * Class: TAPViewController
 * Type: Controller of view of app
 * --------------------------
 * Extends UIViewController (duh)
 *
 * Conforms to protocols:
 *		<UIAlertViewDelegate>
 *
 * Controls the front view of the app.
 * Provides text field to enter summonerName and sign in.
 */
@interface TAPViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

@property (weak, nonatomic) IBOutlet UITextField *signInField;

- (IBAction)signIn:(id)sender;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

