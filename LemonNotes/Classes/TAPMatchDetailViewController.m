
#import "TAPMatchDetailViewController.h"

@interface TAPMatchDetailViewController ()

//table
@property (nonatomic, weak) IBOutlet UITableView *tableView;

//setup
- (void)setupNavbar;
- (void)setupTableView;

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
 * Sets up the navbar.
 * Hard resets navbar's y-origin to 20 in case it was scrolled up
 * by NavBarController in the main MatchHistoryVC.
 * Sets the title to HelveticaNeue 20 white.
 */
- (void)setupNavbar
{
    UINavigationBar *navbar = self.navigationController.navigationBar;
    
    //adjust frame
    CGRect frame = navbar.frame;
    frame.origin.y = 20;
    navbar.frame = frame;
    
    //set to white
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"HelveticaNeue" size:20], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    navbar.titleTextAttributes = attributes;
}

/**
 * @method setupTableView
 *
 * Sets up the tableView.
 * Points delegate and dataSource to this
 */
- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


#pragma mark - TableView
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return nil;
}

@end
