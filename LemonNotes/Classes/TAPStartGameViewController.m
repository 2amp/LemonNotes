
#import "TAPStartGameViewController.h"
#import "DataManager.h"
#import "SummonerManager.h"



@interface TAPStartGameViewController ()

@property NSMutableArray *teammateFields;
@property NSMutableArray *teammateChecks;
@property NSMutableArray *teammateManagers;
@property NSMutableArray *teammateIndicators;

@property NSMutableArray *teammateNames;

@end



@implementation TAPStartGameViewController

#pragma mark - Init Methods
/**
 * @method viewDidLoad
 * 
 * Called when view is loaded to memory
 * Sets the summoner name label text to the name of the summoner.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.teammateFields = [NSMutableArray arrayWithArray:@[self.teammate0Field, self.teammate1Field, self.teammate2Field, self.teammate3Field]];
    self.teammateChecks = [NSMutableArray arrayWithArray:@[self.teammate0Check, self.teammate1Check, self.teammate2Check, self.teammate3Check]];
    self.teammateIndicators = [NSMutableArray arrayWithArray:@[self.teammate0Indicator, self.teammate1Indicator, self.teammate2Indicator, self.teammate3Indicator]];
    self.teammateManagers = [NSMutableArray arrayWithCapacity:5];
    self.teammateNames = [[NSMutableArray alloc] init];
    self.summonerNameLabel.text = self.summonerName;
    NSLog(@"%@ %p", self.class, self);
}

/**
 * @method didReceiveMemoryWarning
 *
 * Called when VC is overusing memory
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * When the user presses return or moves focus off of the text field, initializes
 * a SummonerManager for the entered summoner name if it is valid and displays
 * a checkmark next to the name. Otherwise, displays an X next to the name.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = [self.teammateFields indexOfObject:textField];
    if (![textField.text isEqualToString:@""])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.teammateIndicators[index] startAnimating];
        });
        [DataManager getSummonerForName:textField.text
                                 region:@"na"
                         successHandler:^(NSDictionary *summoner) {
                             ((UIImageView *)self.teammateChecks[index]).image = [UIImage imageNamed:@"checkmark.png"];
                             self.teammateManagers[index] = [[SummonerManager alloc] initWithSummoner:summoner];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.teammateIndicators[index] stopAnimating];
                             });

                         }
                         failureHandler:^(NSString *errorMessage) {
                             ((UIImageView *)self.teammateChecks[index]).image = [UIImage imageNamed:@"cross.png"];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.teammateIndicators[index] stopAnimating];
                             });
                         }];
    }
    NSLog(@"%lu", index);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
