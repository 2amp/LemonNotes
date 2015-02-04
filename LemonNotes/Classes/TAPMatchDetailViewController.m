
#import "TAPMatchDetailViewController.h"

@interface TAPMatchDetailViewController ()

//setup
- (void)setupNavbar;

@end
#pragma mark -


@implementation TAPMatchDetailViewController
#pragma mark View Load Cycle
/**
 * @method viewDidLoad
 *
 * Called once when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

/**
 * @method viewWillAppear
 *
 * Called every time view is about to enter the screen
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNavbar];
}


#pragma mark - Setup
/**
 * @method setupNavbar
 *
 * Sets up the navbar
 */
- (void)setupNavbar
{
    UINavigationBar *navbar = self.navigationController.navigationBar;
    navbar.tintColor = [UIColor whiteColor];
    CGRect frame = navbar.frame;
    frame.origin.y = 20;
    navbar.frame = frame;
}

@end
