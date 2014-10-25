
#import <UIKit/UIKit.h>

/**
 * Class: TAPSignInViewController
 * Type: Root view controller
 * --------------------------
 * Initial view controller presented to the user. Contains a text field for the 
 * user to enter summonerName and sign in.
 */
@interface TAPSignInViewController : UIViewController
            <UIAlertViewDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *idNumber;

@end

