
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

#pragma mark - View Messages
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {

    }
    return self;
}

/**
 * @method viewDidLoad
 *
 * Called when view
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recentGames = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentGames"];
    [self update:self];
}

#pragma mark - Private methods
/**
 * @method updateSummonerInfo
 *
 *
 */
- (IBAction)update:(id)sender
{
    NSString *summonerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerId"];
    NSLog(@"summonerId: %@", summonerId);

    void (^summonerInfoHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.summonerInfo = jsonData[[jsonData allKeys][0]];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *iconPath = [NSString stringWithFormat:@"%@.png", [self.summonerInfo objectForKey:@"profileIconId"]];
            self.summonerIconView.image = [UIImage imageNamed:iconPath scaledToWidth:100 height:100];
            self.summonerNameLabel.text = [self.summonerInfo objectForKey:@"name"];
            self.summonerRankLabel.text = [NSString stringWithFormat:@"Level %@", [self.summonerInfo objectForKey:@"summonerLevel"]];
        });
    };

    NSURLSessionDataTask *summonerInfoDataTask = [[NSURLSession sharedSession] dataTaskWithURL:apiURL(kLoLSummoner, @"na", summonerId)
                                                                             completionHandler:summonerInfoHandler];
    [summonerInfoDataTask resume];
}

#pragma mark - IBActions
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
 * @param tableView requesting the data
 * @param section   to get number of rows
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
    NSDictionary *participant = match[@"participants"][0];
    NSDictionary *stats = participant[@"stats"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];
    RiotDataManager *dataManager = [RiotDataManager sharedManager];

    // Configure the cell...
    UILabel *outcome = (UILabel *)[cell viewWithTag:100];
    UIImageView *championImageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *championName = (UILabel *)[cell viewWithTag:102];
    UIImageView *summonerIcon1ImageView = (UIImageView *)[cell viewWithTag:103];
    UIImageView *summonerIcon2ImageView = (UIImageView *)[cell viewWithTag:104];
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:105];

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

    NSString *imagePath = [NSString stringWithFormat:@"%@.png", [dataManager championKeyForId:participant[@"championId"]]];
    UIImage *championImage = [UIImage imageNamed:imagePath scaledToWidth:60 height:60];
    championImageView.image = championImage;

    NSString *summonerIcon1ImagePath = [NSString stringWithFormat:@"%@.png", [dataManager summonerSpellKeyForId:participant[@"spell1Id"]]];
    UIImage *summonerIcon1Image = [UIImage imageNamed:summonerIcon1ImagePath];
    NSString *summonerIcon2ImagePath = [NSString stringWithFormat:@"%@.png", [dataManager summonerSpellKeyForId:participant[@"spell2Id"]]];
    UIImage *summonerIcon2Image = [UIImage imageNamed:summonerIcon2ImagePath];
    summonerIcon1ImageView.image = summonerIcon1Image;
    summonerIcon2ImageView.image = summonerIcon2Image;

    scoreLabel.text = [NSString stringWithFormat:@"%@/%@/%@", stats[@"kills"], stats[@"deaths"], stats[@"assists"]];

    championName.text = [dataManager championNameForId:participant[@"championId"]];
    return cell;
}

@end
