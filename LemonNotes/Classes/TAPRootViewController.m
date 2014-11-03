
#import "TAPRootViewController.h"
#import "TAPSideMenuViewController.h"

@interface TAPRootViewController ()

@end

@implementation TAPRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Initializes the content vc and left menu vc (side menu vc). The side menu vc's
 * array of content vcs is populated here.
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sideMenuVC"];
    TAPSideMenuViewController *sideMenuViewController = (TAPSideMenuViewController *)self.leftMenuViewController;
    sideMenuViewController.contentViewControllers = @[self.contentViewController,  [self.storyboard instantiateViewControllerWithIdentifier:@"startGameVC"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
