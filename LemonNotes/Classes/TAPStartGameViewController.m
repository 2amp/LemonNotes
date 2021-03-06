
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
 * Sets the summoner name label text to the name of the summoner and performs a
 * bunch of setup.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

    // FIXME: A bunch of setup that should probably not be hardcoded if we want to take into account
    // other game modes in the future
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
 * Currently fetches the 30 most recent matches for each entered summoner.
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
                                 [matches addObjectsFromArray:[manager loadFromServer:self.matchesToFetchField.selectedItem.intValue]];
                                 self.teammateRecentMatches[index] = matches;
                                 // Update UI on main thread
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     ((UIImageView *)self.teammateChecks[index]).image = [UIImage imageNamed:@"checkmark.png"];
                                     [self.teammateIndicators[index] stopAnimating];
                                     NSLog(@"%lu", [self.teammateRecentMatches[index] count]);
                                 });
                             });
                             self.teammateManagers[index] = manager;
                         }
                         failureHandler:^(NSString *errorMessage) {
                             // Handler callbacks are already called on the main thread, so we don't need to wrap this
                             // in a dispatch_async block
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
    // dismiss keyboard upon losing focus
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showStats"])
    {
        TAPTeammateInfoViewController *teammateInfoVC = (TAPTeammateInfoViewController *)segue.destinationViewController;
        teammateInfoVC.teammateManagers = self.teammateManagers;
        teammateInfoVC.teammateRecentMatches = self.teammateRecentMatches;
        for (NSArray *array in self.teammateRecentMatches)
        {
            NSLog(@"%lu", array.count);
        }
    }
}

@end
