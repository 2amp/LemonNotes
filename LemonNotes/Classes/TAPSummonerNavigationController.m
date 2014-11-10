
#import "TAPSummonerNavigationController.h"
#import "TAPSummonerViewController.h"



@interface TAPSummonerNavigationController()

@end



@implementation TAPSummonerNavigationController
/**
 * @method viewDidLoad
 *
 * Called when navigation controller is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TAPSummonerViewController *rootSummonerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"summonerVC"];
    rootSummonerVC.summoner = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    [self pushViewController:rootSummonerVC animated:YES];
}

/**
 * @method viewWillLoad
 *
 * Called every time before nav controller will load
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}



@end
