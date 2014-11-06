
#import "TAPHomeViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "RiotDataManager.h"
#import "Constants.h"



@interface TAPHomeViewController()

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerRankLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;

- (IBAction)update:(id)sender;

@end



@implementation TAPHomeViewController

#pragma mark View Messages
/**
 * @method viewDidLoad
 *
 * Called when view
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self update:self];
    NSLog(@"TAPHomeViewController viewDidLoad %p", &self);
}



#pragma mark - IBActions
/**
 * @method updateSummonerInfo
 *
 *
 */
- (IBAction)update:(id)sender
{
    NSNumber *summonerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerId"];
    [[RiotDataManager sharedManager] updateGamesForSummoner:summonerId];
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
    return self.recentGames.count;
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
    NSDictionary *match = self.recentGames[indexPath.row];
    NSDictionary *stats = match[@"stats"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];
    RiotDataManager *dataManager = [RiotDataManager sharedManager];

    // Configure the cell...
    UILabel     *outcome                = (UILabel *)    [cell viewWithTag:100];
    UIImageView *championImageView      = (UIImageView *)[cell viewWithTag:101];
    UILabel     *championName           = (UILabel *)    [cell viewWithTag:102];
    UIImageView *summonerIcon1ImageView = (UIImageView *)[cell viewWithTag:103];
    UIImageView *summonerIcon2ImageView = (UIImageView *)[cell viewWithTag:104];
    UILabel     *scoreLabel             = (UILabel *)    [cell viewWithTag:105];

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

    NSString *imagePath = [NSString stringWithFormat:@"%@.png", [dataManager championKeyForId:match[@"championId"]]];
    UIImage *championImage = [UIImage imageNamed:imagePath scaledToWidth:60 height:60];
    championImageView.image = championImage;

    NSString *summonerIcon1ImagePath = [NSString stringWithFormat:@"%@.png", [dataManager summonerSpellKeyForId:match[@"spell1Id"]]];
    UIImage *summonerIcon1Image = [UIImage imageNamed:summonerIcon1ImagePath];
    NSString *summonerIcon2ImagePath = [NSString stringWithFormat:@"%@.png", [dataManager summonerSpellKeyForId:match[@"spell2Id"]]];
    UIImage *summonerIcon2Image = [UIImage imageNamed:summonerIcon2ImagePath];
    summonerIcon1ImageView.image = summonerIcon1Image;
    summonerIcon2ImageView.image = summonerIcon2Image;
    
    NSNumber *kills = stats[@"championsKilled"] ? stats[@"championsKilled"] : @0;
    NSNumber *deaths = stats[@"numDeaths"] ? stats[@"numDeaths"] : @0;
    NSNumber *assists = stats[@"assists"] ? stats[@"assists"] : @0;
    scoreLabel.text = [NSString stringWithFormat:@"%@/%@/%@", kills, deaths, assists];

    championName.text = [dataManager championNameForId:match[@"championId"]];
    return cell;
}

@end
