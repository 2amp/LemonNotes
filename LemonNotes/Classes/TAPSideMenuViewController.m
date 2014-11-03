
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // FIXME: Currently instantiates a new vc every time we switch between vcs. We'll probably have to keep a reference to
    // each vc so we don't keep instantiating new vcs?
    switch (indexPath.row)
    {
        case 0:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"gameStartVC"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
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
 * TODO: Will change in the future.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

/**
 *
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
