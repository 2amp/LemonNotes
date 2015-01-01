
#import "TAPStartGameViewController.h"
#import "TAPDataManager.h"
#import "TAPSummonerManager.h"
#import "TAPTeammateInfoViewController.h"



@interface TAPStartGameViewController ()

@property NSMutableArray *teammateFields;
@property NSMutableArray *teammateChecks;
@property NSMutableArray *teammateManagers;
@property NSMutableArray *teammateIndicators;
@property NSMutableArray *teammateRecentMatches;
@property NSString *currentlyEditedName;

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
    self.teammateManagers = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
    self.teammateRecentMatches = [NSMutableArray arrayWithObjects:@[], @[], @[], @[], nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentlyEditedName = textField.text;
}

/**
 * When the user presses return or moves focus off of the text field, initializes
 * a SummonerManager for the entered summoner name if it is valid and displays
 * a checkmark next to the name. Otherwise, displays an X next to the name.
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = [self.teammateFields indexOfObject:textField];
    if (![textField.text isEqualToString:@""] && ![textField.text isEqualToString:self.currentlyEditedName])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UIImageView *)self.teammateChecks[index]).image = nil;
            [self.teammateIndicators[index] startAnimating];
        });
        [TAPDataManager getSummonerForName:textField.text
                                 region:@"na"
                         successHandler:^(NSDictionary *summoner) {
                             TAPSummonerManager *manager = [[TAPSummonerManager alloc] initWithSummoner:summoner];
                             manager.delegate = self;
                             // [manager loadServer] is synchronous, so place in async block
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                 NSMutableArray *matches = [[NSMutableArray alloc] init];
                                 [matches addObjectsFromArray:[manager loadFromServer]];
                                 [matches addObjectsFromArray:[manager loadFromServer]];
                                 self.teammateRecentMatches[index] = matches;
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     ((UIImageView *)self.teammateChecks[index]).image = [UIImage imageNamed:@"checkmark.png"];
                                     [self.teammateIndicators[index] stopAnimating];
                                     NSLog(@"%lu", [self.teammateRecentMatches[index] count]);
                                 });
                             });
                             self.teammateManagers[index] = manager;
                         }
                         failureHandler:^(NSString *errorMessage) {
                             ((UIImageView *)self.teammateChecks[index]).image = [UIImage imageNamed:@"cross.png"];
                             [self.teammateIndicators[index] stopAnimating];
                         }];
    }
    NSLog(@"%lu", index);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.matchesToFetchField)
    {
        [self.matchesToFetchField showPicker];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
