
#import <UIKit/UIKit.h>
#import "TAPSummonerManager.h"
#import "TAPPickerTextField.h"

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
@interface TAPStartGameViewController : UIViewController <UITextFieldDelegate, TAPSummonerManagerDelegate>

@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *idNumber;

@property (weak, nonatomic) IBOutlet UILabel *summonerNameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sideControl;
@property (weak, nonatomic) IBOutlet UISwitch *captainSwitch;

@property (weak, nonatomic) IBOutlet UITextField *teammate0Field;
@property (weak, nonatomic) IBOutlet UITextField *teammate1Field;
@property (weak, nonatomic) IBOutlet UITextField *teammate2Field;
@property (weak, nonatomic) IBOutlet UITextField *teammate3Field;

@property (weak, nonatomic) IBOutlet UIImageView *teammate0Check;
@property (weak, nonatomic) IBOutlet UIImageView *teammate1Check;
@property (weak, nonatomic) IBOutlet UIImageView *teammate2Check;
@property (weak, nonatomic) IBOutlet UIImageView *teammate3Check;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *teammate0Indicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *teammate1Indicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *teammate2Indicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *teammate3Indicator;

@property (weak, nonatomic) IBOutlet TAPPickerTextField *matchesToFetchField;

@property (nonatomic, strong) NSString *selectedRegion;

@end
