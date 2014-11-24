
#import "TAPStartGameViewController.h"



@interface TAPStartGameViewController ()

@property NSArray *teammateFields;
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

    self.teammateFields = @[self.teammate0Field, self.teammate1Field, self.teammate2Field, self.teammate3Field];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = [self.teammateFields indexOfObject:textField];
    NSLog(@"%lu", index);
    [textField resignFirstResponder];
    return YES;
}

@end
