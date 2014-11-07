
#import "TAPHomeViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "DataManager.h"
#import "Constants.h"



@interface TAPHomeViewController()

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerLevelLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;

- (IBAction)update:(id)sender;

@end



@implementation TAPHomeViewController

#pragma mark View Messages
/**
 * @method viewDidLoad
 *
 * Called when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"TAPHomeViewController viewDidLoad %p", &self);
}

/**
 * @method viewWillAppear
 *
 * Called when view will appear
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSDictionary *summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    self.summonerNameLabel.text = summonerInfo[@"name"];
    self.summonerLevelLabel.text = [NSString stringWithFormat:@"Level: %@", summonerInfo[@"summonerLevel"]];
    self.summonerIconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", summonerInfo[@"profileIconId"]]];
}



#pragma mark - IBActions
/**
 * @method updateSummonerInfo
 *
 *
 */
- (IBAction)update:(id)sender
{
    
}

/**
 * When the matches button is tapped, segue to the tab bar vc.
 */
- (IBAction)matchesTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showTabBar" sender:self];
}



#pragma mark - Navigation Events
/**
 * Currently no segue from the main vc occurs. Will soon change!
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}



#pragma mark - Table View Data Source Methods
/**
 * @method numberOfSectionsInTableView:
 *
 * Returns 1 because match history only has 1 section
 *
 * @param tableView requesting the data
 * @return 1
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 * @method tableView:numberOfRowsInSection:
 *
 * Returns the number of recentGames
 *
 * @param tableView the table view requesting the data
 * @param section the section to get number of rows from
 * @return number of rows in given section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DataManager sharedManager].recentMatches.count;
}

/**
 * @method tableView:cellForRowAtIndexPath
 *
 * Generates a match history table cell based on the matchHistoryCell prototype
 * in Main.storyboard.
 *
 * @param tableView requesting data
 * @param indexPath the index path of the requested cell
 * @return cell containing critical match information
 *
 * @code View tags
 * 100: (UILabel *)         Outcome label
 * 101: (UIImageView *)     Champion icon
 * 102: (UILabel *)         Champion name label
 * 103: (UIImageView *)     Summoner spell 1 icon
 * 104: (UIImageView *)     Summoner spell 2 icon
 * 105: (UILabel *)         Score label
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];
    UILabel     *outcome                = (UILabel *)    [cell viewWithTag:100];
    UIImageView *championImageView      = (UIImageView *)[cell viewWithTag:101];
    UILabel     *championName           = (UILabel *)    [cell viewWithTag:102];
    UIImageView *summonerIcon1ImageView = (UIImageView *)[cell viewWithTag:103];
    UIImageView *summonerIcon2ImageView = (UIImageView *)[cell viewWithTag:104];
    UILabel     *scoreLabel             = (UILabel *)    [cell viewWithTag:105];
    
    //pull data
    DataManager *dataManager = [DataManager sharedManager];
    NSDictionary *match = dataManager.recentMatches[indexPath.row];
    int summonerIndex = [match[@"summonerIndex"] intValue];
    NSDictionary *info  = match[@"participants"][summonerIndex];
    NSDictionary *stats = info[@"stats"];

    if ([stats[@"winner"] boolValue])
    {
        outcome.text = @"Victory";
        outcome.textColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
    }
    else
    {
        outcome.text = @"Defeat";
        outcome.textColor = [UIColor redColor];
    }

    //set images
    NSString *champion = dataManager.champions[ [info[@"championId"] stringValue] ][@"key"];
    NSString *spell1   = dataManager.summonerSpells[ [info[@"spell1Id"] stringValue] ][@"key"];
    NSString *spell2   = dataManager.summonerSpells[ [info[@"spell2Id"] stringValue] ][@"key"];
    championImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", champion]];
    summonerIcon1ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", spell1]];
    summonerIcon2ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", spell2]];
    
    //set labels
    NSNumber *kills   = stats[@"kills"]   ? stats[@"kills"]   : @0;
    NSNumber *deaths  = stats[@"deaths"]  ? stats[@"deaths"]  : @0;
    NSNumber *assists = stats[@"assists"] ? stats[@"assists"] : @0;
    scoreLabel.text = [NSString stringWithFormat:@"%@/%@/%@", kills, deaths, assists];

    championName.text = dataManager.champions[ [info[@"championId"] stringValue] ][@"name"];
    return cell;
}

@end
