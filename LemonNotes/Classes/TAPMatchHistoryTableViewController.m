
#import "TAPMatchHistoryTableViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "RiotDataManager.h"



@interface TAPMatchHistoryTableViewController ()

@end



@implementation TAPMatchHistoryTableViewController
#pragma mark - Init Methods
/**
 * Method: viewDidLoad
 * Usage: called when view has loaded
 * --------------------------
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/**
 * Method: didReceiveMemoryWarning
 * Usage: called when memory warning is fired
 * --------------------------
 *
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source Methods
/**
 * Method: numberOfSectionsInTableView:
 * Usage: called automatically
 * --------------------------
 * The match history table view only has one section.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/**
 * Method: tableView:numberOfRowsInSection:
 * Usage: called automatically
 * --------------------------
 *
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recentGames.count;
}

/**
 * Generates a match history table cell based on the matchHistoryCell prototype 
 * in Main.storyboard.
 * @param tableView
 * @param indexPath the index path of the requested cell
 *
 * @code View tags
 * 100: (UILabel *)         Outcome label
 * 101: (UIImageView *)     Champion icon
 * 102: (UILabel *)         Champion name label
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *match = self.recentGames[indexPath.row];
    NSDictionary *participant = match[@"participants"][0];
    NSDictionary *stats = participant[@"stats"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *outcome = (UILabel *)[cell viewWithTag:100];
    if ([stats[@"winner"] boolValue])
    {
        outcome.text = @"Win";
    }
    else
    {
        outcome.text = @"Defeat";
    }
    UIImageView *championImageView = (UIImageView *)[cell viewWithTag:101];
    NSString *imagePath = [NSString stringWithFormat:@"%@.png", [[RiotDataManager sharedManager] championKeyForId:participant[@"championId"]]];
    UIImage *championImage = [UIImage imageNamed:imagePath scaledToWidth:60 height:60];
    championImageView.image = championImage;
    UILabel *championName = (UILabel *)[cell viewWithTag:102];
    championName.text = [[RiotDataManager sharedManager] championNameForId:participant[@"championId"]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
