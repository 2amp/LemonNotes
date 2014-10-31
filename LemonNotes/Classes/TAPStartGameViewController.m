
#import "TAPStartGameViewController.h"



@interface TAPStartGameViewController ()

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
    
    self.summonerNameLabel.text = self.summonerName;
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

@end
