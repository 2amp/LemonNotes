
#import "TAPSummonerViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "TAPLemonRefreshControl.h"
#import "TAPSearchField.h"
#import "DataManager.h"
#import "Constants.h"



@interface TAPSummonerViewController()

//summoner
@property (nonatomic, strong) SummonerManager *manager;

//Nav bar
@property (nonatomic, weak) IBOutlet TAPSearchField* searchField;

//Header
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerLevelLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;
@property (nonatomic, weak) IBOutlet UIImageView* championSplashView;

//table
@property (nonatomic, strong) NSMutableArray* matches;
@property (nonatomic, strong) TAPLemonRefreshControl* refreshControl;

//setup
- (void)setupHeader;
- (void)setupTableView;

@end



@implementation TAPSummonerViewController

#pragma mark Setup
/**
 * @method setSummoner:
 *
 * Setter for summoner. After setting summoner dictionary,
 * creates a SummonerManager with same summoner info.
 */
- (void)setSummoner:(NSDictionary *)summoner
{
    _summoner = summoner;
    self.manager = [[SummonerManager alloc] initWithSummoner:summoner];
}

/**
 * @method viewDidLoad
 *
 * Called once when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@ %p", self.class, self);
    
    //if rootVC of nav
    if (self == [self.navigationController.viewControllers firstObject])
    {
        self.summoner = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    }
    
    //setups
    [self setupHeader];
    [self setupTableView];
}

/**
 * @method setupHeader
 *
 * Sets up the header components
 */
- (void)setupHeader
{
    //setup basic header elems
    self.summonerNameLabel.text  = self.summoner[@"name"];
    self.summonerLevelLabel.text = [NSString stringWithFormat:@"Level: %@", self.summoner[@"summonerLevel"]];
    self.summonerIconView.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.summoner[@"profileIconId"]]];
    
    //white border for summoner icon
    [self.summonerIconView.layer setBorderWidth:2.0];
    [self.summonerIconView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    //latest champ splash
    DataManager *manager = [DataManager sharedManager];
    NSDictionary *match = manager.recentMatches[0];
    int summonerIndex = [match[@"summonerIndex"] intValue];
    NSString *champId = [match[@"participants"][summonerIndex][@"championId"] stringValue];
    NSString *champKey = manager.champions[champId][@"key"];
    [[self.tableView tableHeaderView] sendSubviewToBack:self.championSplashView];
    self.championSplashView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_0.jpg", champKey]];
    
    //landscape: put header behind table view
    [self.tableView sendSubviewToBack:[self.tableView tableHeaderView]];
}

/**
 * @method setupTableView
 *
 * Sets up table view components
 */
- (void)setupTableView
{
    //styling
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //data
    self.matches = [[NSMutableArray alloc] init];
    
    //custom refresh control
    self.refreshControl = [[TAPLemonRefreshControl alloc] init];
    [self setRefreshControl:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}



#pragma mark - SummonerManager
- (void)didFinishLoadingMatches:(NSArray *)moreMatches
{
    //append loaded matches to matches
    [self.matches addObjectsFromArray:moreMatches];
}

- (void)didFinishRefreshingMatches:(NSArray *)matches
{
    [self.refreshControl endRefreshing];
}



#pragma mark - Table View
- (void)refresh
{
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"DONE");
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
}

/**
 * @method scrollViewDidScroll:
 *
 * Called whenever view is scrolled (by dragging).
 * Tells custom refresh control that scroll happened,
 * and passes on how much it has been dragged
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollY = self.tableView.contentOffset.y;
    if (scrollY < 0)
    {
        [self.refreshControl pulledTo:self.tableView.contentOffset.y];
    }
}

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

    //
    championImageView.layer.cornerRadius = championImageView.frame.size.width / 2;
    championImageView.layer.borderColor = [UIColor blackColor].CGColor;
    championImageView.layer.borderWidth = 2.0f;
    championImageView.clipsToBounds = YES;

    // Debug
    UILabel *matchNumberLabel = (UILabel *)[cell viewWithTag:200];

    // items
    UIImageView *item0ImageView = (UIImageView *)[cell viewWithTag:300];
    UIImageView *item1ImageView = (UIImageView *)[cell viewWithTag:301];
    UIImageView *item2ImageView = (UIImageView *)[cell viewWithTag:302];
    UIImageView *item3ImageView = (UIImageView *)[cell viewWithTag:303];
    UIImageView *item4ImageView = (UIImageView *)[cell viewWithTag:304];
    UIImageView *item5ImageView = (UIImageView *)[cell viewWithTag:305];
    UIImageView *item6ImageView = (UIImageView *)[cell viewWithTag:306];

    NSArray *itemImageViews = @[item0ImageView, item1ImageView, item2ImageView, item3ImageView, item4ImageView, item5ImageView, item6ImageView];
    
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

    // items
    NSArray *items = @[stats[@"item0"], stats[@"item1"], stats[@"item2"], stats[@"item3"], stats[@"item4"], stats[@"item5"], stats[@"item6"]];
    for (int i = 0; i < itemImageViews.count; i++)
    {
        NSString *itemKey = [items[i] stringValue];
        if ([itemKey isEqualToString:@"0"])
            itemKey = @"0000";
        ((UIImageView *)itemImageViews[i]).image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", itemKey]];
    }

    //set labels
    NSNumber *kills   = stats[@"kills"];
    NSNumber *deaths  = stats[@"deaths"];
    NSNumber *assists = stats[@"assists"];
    scoreLabel.text = [NSString stringWithFormat:@"%@/%@/%@", kills, deaths, assists];

    championName.text = dataManager.champions[ [info[@"championId"] stringValue] ][@"name"];

    // debug
    matchNumberLabel.text = [[NSNumber numberWithInteger:(indexPath.row + 1)] stringValue];
    return cell;
}

/**
 * @method tableView:didSelectRowAtIndexPath:
 *
 * Called when user taps a match history cell.
 * Performs segue to match detail VC (or should)
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showNextViewController" sender:self];
}



#pragma mark - Navigation Events
/**
 * @method textFieldShouldReturn:
 *
 * Called when user presses Go on searchField.
 * Passes on name & region to searchSummonerWithName:Region:
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchSummonerWithName:self.searchField.text Region:self.searchField.selectedRegion];
    
    [textField resignFirstResponder];
    return YES;
}

/**
 * @method searchSummonerWithName:Region:
 *
 * Given a name & region, retreives summoner
 * on a background thread through API call.
 * Instantiates new summonerVC, passes on the summoner,
 * and manually pushes to navigation stack on main queue.
 *
 * @param name   - summoner name
 * @param region - summoner region
 */
- (void)searchSummonerWithName:(NSString *)name Region:(NSString *)region
{
    //start activity indicator
    
    dispatch_queue_t newQ = dispatch_queue_create("temp", DISPATCH_QUEUE_SERIAL);
    dispatch_async(newQ,
    ^{
        NSError *error;
        NSHTTPURLResponse *response;
        NSURL *url = apiURL(kLoLSummonerByName, region, name, @[]);
        NSData *data = [[NSURLSession sharedSession] sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
        
        //should include some check for not existing summoner
        
        NSDictionary *summoner = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][name];
        
        dispatch_async(dispatch_get_main_queue(),
        ^{
            //stop activity indicator
            
            TAPSummonerViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"summonerVC"];
            nextVC.summoner = summoner;
            [self.navigationController pushViewController:nextVC animated:YES];
        });
    });
}

/**
 * Currently no segue from the main vc occurs. Will soon change!
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
