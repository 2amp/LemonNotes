
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
//@property (nonatomic, weak) IBOutlet TAPSearchField* searchField;

//table
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* matches;
@property (nonatomic, strong) TAPLemonRefreshControl* lemonRefresh;

//Header
@property (nonatomic) BOOL needsUpdate;
@property (nonatomic, weak) IBOutlet UIView*  header;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerLevelLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;
@property (nonatomic, weak) IBOutlet UIImageView* championSplashView;

//footer
@property (nonatomic, weak) IBOutlet UIView* footer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* footerIndicator;

//scroll
@property (nonatomic) CGFloat previousOffset;
@property (nonatomic) CGFloat startingOffset;
@property (nonatomic) BOOL loadLock;

//setup
- (void)setupTableView;
- (void)setupHeaderFooter;
- (void)setupScrollEvents;

@end
#pragma mark -


@implementation TAPSummonerViewController

#pragma mark View Load Cycle
/**
 * @method viewDidLoad
 *
 * Called once when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"%@ %p", self.class, self);
    NSLog(@"SummonerVC [viewDidLoad]");
    
    if (self == [self.navigationController.viewControllers firstObject])
    {
        NSString *summonerName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"] objectForKey:@"name"];
        self.summonerNameLabel.text  = summonerName;
        self.summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
        [self.manager registerSummoner];
    }
    
    [self setupTableView];
    [self setupHeaderFooter];
    [self setupScrollEvents];
    
    self.needsUpdate = YES;
    [self.manager loadMatches];
}

/**
 * @method: viewWillAppear:
 *
 * Called when this view is about to appear.
 * Setup all necessary components, 
 * then tell manager to load matches.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSLog(@"SummonerVC [viewWillAppear]");
}



#pragma mark - Setup
/**
 * @method setSummonerInfo:
 *
 * Setter for summoner. After setting summoner dictionary,
 * creates a SummonerManager with same summoner info.
 * @note Should only be called once for every instance of SummonerVC
 */
- (void)setSummonerInfo:(NSDictionary *)summonerInfo
{
    NSLog(@"SummonerVC [setSummonerInfo]");
    _summonerInfo = summonerInfo;
    self.manager = [[SummonerManager alloc] initWithSummoner:summonerInfo];
    self.manager.delegate = self;
}

/**
 * @method setupTableView
 *
 * Setup for table view.
 * Sets delegate & datasource to this.
 * Initialize matches array for data pool.
 * Position table according to nav bar.
 * Append refresh control.
 */
- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.matches = [[NSMutableArray alloc] init];
    
    //Position
    CGRect navbarFrame = self.navigationController.navigationBar.frame;
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = CGRectGetMaxY(navbarFrame);
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
    NSLog(@"inset: %f, offset: %f, wanted inset: %f", self.tableView.contentInset.top, self.tableView.contentOffset.y, inset.top);
    [self.view sendSubviewToBack:self.tableView];
    
    //refresh
    //self.lemonRefresh = [[TAPLemonRefreshControl alloc] initWithTableView:self.tableView];
    //[self.lemonRefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

/**
 * @method setupHeaderFooter
 *
 * Sets up the header components, excluding splash art.
 * Makes footer visible with indicator spinning.
 *
 * @note Assumes that summonerManager has been setup
 *       and that matches array is not empty.
 */
- (void)setupHeaderFooter
{
    //setup basic header elems
    self.summonerNameLabel.text  = self.summonerInfo[@"name"];
    self.summonerLevelLabel.text = [NSString stringWithFormat:@"Level: %@", self.summonerInfo[@"summonerLevel"]];
    self.summonerIconView.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.summonerInfo[@"profileIconId"]]];
    
    //white border for summoner icon
    [self.summonerIconView.layer setBorderWidth:2.0];
    [self.summonerIconView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    //landscape: put header behind table view
    [self.tableView sendSubviewToBack:[self.tableView tableHeaderView]];
    
    //footer
    [self showFooter:YES];
}

/**
 * @method setupScrollEvents
 *
 * Sets several constants needed for handling scroll events.
 */
- (void)setupScrollEvents
{
    
}


#pragma mark - UI Control
/**
 * @method showAlertWithTitle:message:
 *
 * Creates an UIAlertView object with the given title & message
 * along with self as delegate, "OK" as cancel button, and no other buttons.
 * Immediately shows the window
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

/**
 * @updateHeaderSplash
 *
 * Sets champion splash background to one
 * of the most recently played match.
 */
- (void)updateHeaderSplash
{
    NSDictionary *match = [self.matches firstObject];
    int summonerIndex = [match[@"summonerIndex"] intValue];
    NSString *champId = [match[@"participants"][summonerIndex][@"championId"] stringValue];
    NSString *champKey = [DataManager sharedManager].champions[champId][@"key"];
    [[self.tableView tableHeaderView] sendSubviewToBack:self.championSplashView];
    self.championSplashView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_0.jpg", champKey]];
}

/**
 * @method showFooter:
 *
 * Given a bool, either shows footer or hides it.
 * @param show - whether to show or hide footer
 */
- (void)showFooter:(BOOL)show
{
    CGSize size = self.footer.frame.size;
    if (show) //show
    {
        self.footer.hidden = NO;
        self.footer.frame = CGRectMake(0,0,size.width,44);
        self.tableView.tableFooterView = self.footer;
        
        [self.footerIndicator startAnimating];
    }
    else //dont show
    {
        self.footer.hidden = YES;
        self.footer.frame = CGRectMake(0,0,size.width,10);
        self.tableView.tableFooterView = self.footer;
        
        [self.footerIndicator stopAnimating];
    }
}


#pragma mark - Summoner Manager
/**
 * @method didFinishLoadingMatches:
 *
 * Called by SummonerManager as delegate callback
 *  when [loadMatches] has been completed.
 */
- (void)didFinishLoadingMatches:(NSArray *)moreMatches
{
    if (moreMatches.count > 0)
    {
        self.loadLock = NO;
    
        //append loaded matches to matches
        [self.matches addObjectsFromArray:moreMatches];
        [self.tableView reloadData];
        [self updateHeaderSplash];
        
        //no more loading necessary
        if (moreMatches.count < 15)
        {
            self.loadLock = YES;
            [self showFooter:NO];
        }
    }
}

/**
 * @method didFinishRefreshingMatches:
 *
 * Called by SummonerManager as delegate callback
 * when [refreshMatches] has been completed.
 */
- (void)didFinishRefreshingMatches:(NSArray *)newMatches
{
    [self.matches insertObjects:newMatches atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newMatches.count)]];
    [self.tableView reloadData];
    
    [self.lemonRefresh endRefreshing];
}


#pragma mark - Scroll View
/**
 * @method scrollViewBeginDragging:
 *
 *
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.startingOffset = scrollView.contentOffset.y;
    self.previousOffset = self.startingOffset;
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
    CGFloat scrolledOffset = scrollView.contentOffset.y;
//    CGFloat delta = scrolledOffset - self.previousOffset;
    self.previousOffset = scrolledOffset;
    
//    if (scrolledOffset > self.startingOffset)
//    {
//        CGRect frame = self.navigationController.navigationBar.frame;
//        frame.size.height -= delta;
//        self.navigationController.navigationBar.frame = frame;
//    }
    
    if (!self.loadLock)
        [self checkForLoad];
}

/**
 * @checkForLoad
 *
 * If tableView has been scrolled enough so that
 * y-offset + screen height >= content height,
 * then after a 1 second delay, manger is called to load more matches.
 */
- (void)checkForLoad
{
    CGFloat footerHeight = self.footer.bounds.size.height;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scrollOffset = self.tableView.contentOffset.y;
    CGFloat contentHeight = self.tableView.contentSize.height;
    
    BOOL loadZone = (screenHeight + scrollOffset <= contentHeight) &&
                    (screenHeight + scrollOffset >= contentHeight - footerHeight);
    
    if (loadZone)
    {
        self.loadLock = YES;
        
        dispatch_time_t secondDelay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(secondDelay, dispatch_get_main_queue(),
        ^{
            [self.manager loadMatches];
        });
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}


#pragma mark - NavBar Scroll



#pragma mark - Table View
/**
 * @method refresh
 *
 * Called when user pulls to refresh.
 * Relays message onto SummonerManager
 */
- (void)refresh
{
    NSLog(@"-[TAPSummonerVC refresh]");
    
    double delayInSeconds = 2.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.lemonRefresh endRefreshing];
    });
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
    return self.matches.count;
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];
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
    NSDictionary *match = self.matches[indexPath.row];
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
    DataManager *dataManager = [DataManager sharedManager];
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
        {
            itemKey = @"0000";
        }
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
    [self performSegueWithIdentifier:@"showGameDetail" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Summoner Search
/**
 * @method textFieldShouldReturn:
 *
 * Called when user presses Go on searchField.
 * Passes on name & region to searchSummonerWithName:Region:
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self searchSummonerWithName:self.searchField.text Region:self.searchField.selectedRegion];
    
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
- (void)searchSummonerWithName:(NSString *)name region:(NSString *)region
{
    //FILL: start activity indicator
    
    //async fetch/search summoner
    [DataManager getSummonerForName:name region:region
    successHandler:^(NSDictionary *summoner)
    {
        //self.searchField.text = @"";
        
        TAPSummonerViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"summonerVC"];
        nextVC.summonerInfo = summoner;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    failureHandler:^(NSString *errorMessage)
    {
        [self showAlertWithTitle:@"Error" message:errorMessage];
    }];
}

#pragma mark - Navigation Events
/**
 * Currently no segue from the main vc occurs. Will soon change!
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
