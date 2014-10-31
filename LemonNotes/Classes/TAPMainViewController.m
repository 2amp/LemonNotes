
#import "TAPMainViewController.h"



@interface TAPMainViewController()

- (IBAction)test:(id)sender;

@end



@implementation TAPMainViewController

#pragma mark View Messages
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *summonerName = [defaults objectForKey:@"summonerName"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}



- (IBAction)test:(id)sender
{
    [self performSegueWithIdentifier:@"showSignIn" sender:self];
}



#pragma mark - Navigation Events


@end
