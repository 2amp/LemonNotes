
#import "TAPSideMenuViewController.h"

@interface TAPSideMenuViewController ()

@end

@implementation TAPSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate
/**
 * When a selection in the side menu is tapped, switches to the selected vc.
 *
 * @param tableView the table view
 * @param indexPath the index path of the selection
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // contentViewControllers is populated by awakeFromNib 
    [self.sideMenuViewController setContentViewController:self.contentViewControllers[indexPath.row] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - Table View Data Source Methods
/**
 * Currently there is only one section in the side menu.
 *
 * @param tableView requesting the data
 * @return 1
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 * TODO: Will change in the future. Currently the only choices are Home and
 * Start Game.
 * @param tableView the table view requesting the data
 * @param section the section to get number of rows from
 * @return number of rows in given section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

/**
 * Generates a match history table cell based on the sideMenuCell prototype
 * in Main.storyboard.
 *
 * @param tableView the table view requesting data
 * @param indexPath the index path of the requested cell
 * @return cell containing a label with the name of the selection
 *
 * @code View tags
 * 100: (UILabel *) Label with name of selection
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideMenuCell" forIndexPath:indexPath];

    // Configure the cell...
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    label.text = [NSString stringWithFormat:@"%@", @[@"Home", @"Start Game"][indexPath.row]];
    return cell;
}

@end
