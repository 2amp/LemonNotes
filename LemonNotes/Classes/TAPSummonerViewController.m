
#import "TAPSummonerViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "TAPScrollNavBarController.h"
#import "TAPLemonRefreshControl.h"
#import "UIView+BorderAdditions.h"
#import "TAPDataManager.h"
#import "TAPSearchField.h"
#import "Constants.h"



@interface TAPSummonerViewController()

//summoner
@property (nonatomic, strong) TAPSummonerManager *manager;

//Nav bar
@property (nonatomic, strong) TAPSearchField* searchField;
@property (nonatomic, strong) TAPScrollNavBarController *navbarController;

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
@property (nonatomic) BOOL loadLock;

//setup
- (void)setupNavbar;
- (void)setupTableView;
- (void)setupHeaderFooter;

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
        self.summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
        [self.manager registerSummoner];
    }
    
    [self setupNavbar];
    [self setupTableView];
    [self setupHeaderFooter];
    
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
    self.manager = [[TAPSummonerManager alloc] initWithSummoner:summonerInfo];
    self.manager.delegate = self;
}

/**
 * @method setupNavbar
 *
 * Sets up elements in/needed for navbar.
 */
- (void)setupNavbar
{
    //back button
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //search field
    self.searchField = [[TAPSearchField alloc] initWithFrame:CGRectMake(0,0,320,22)];
    self.searchField.delegate = self;
    self.searchField.text = self.summonerInfo[@"name"];
    self.navigationItem.titleView = self.searchField;
    
    //scroll navbar
    if (self == [self.navigationController.viewControllers firstObject])
    {
        self.searchField.text = @"";
        self.navbarController = [[TAPScrollNavBarController alloc] initWithNavBar:self.navigationController.navigationBar];
    }
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
    [self.view sendSubviewToBack:self.tableView];
    
    //refresh
    self.lemonRefresh = [[TAPLemonRefreshControl alloc] initWithScrollView:self.tableView];
    [self.lemonRefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
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
    [self.tableView tableFooterView].clipsToBounds = YES;
    [self.tableView sendSubviewToBack:[self.tableView tableHeaderView]];
    
    //footer
    [self showFooter:YES];
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
    NSString *champKey = [TAPDataManager sharedManager].champions[champId][@"key"];
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


#pragma mark - Summoner Manager Delegate Methods
/**
 * @method didFinishLoadingMatches:
 *
 * Called by SummonerManager as delegate callback
 * when -loadMatches has been completed.
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
        
        //NSLog(@"%@", [moreMatches lastObject]);
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


#pragma mark - ScrollView Events
/**
 * @method scrollViewBeginDragging:
 *
 * Called when scrollView is about to start scrolling.
 * Calls navbarController's corresponding method.
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navbarController scrollViewWillBeginDragging:scrollView];
    [self.lemonRefresh scrollViewWillBegingDragging:scrollView];
}

/**
 * @method scrollViewDidScroll:
 *
 * Called whenever view is scrolled (by dragging).
 * Calls navbarController's corresponding method.
 * If loading is not locked, checks for loading matches.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.navbarController scrollViewDidScroll:scrollView];
    [self.lemonRefresh scrollViewDidScroll:scrollView];
    
    if (!self.loadLock) [self checkForLoad];
}

/**
 * @method scrollViewDidEndDragging:willDecelerate:
 *
 * Called when scrollView is no longer actively scrolling.
 * Calls navbarController's corresponding method.
 *
 * @param scrollView - dragging ended on
 * @param decelerate - whether scrollView will slow down
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.navbarController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self.lemonRefresh scrollViewDidEndDragging:scrollView];
}

/**
 * @method scrollViewDidScrollToTop:
 *
 * Called when scrollView reaches the top after tapping on status bar.
 * Calls navbarController's corresponding method.
 *
 * @param scrollView - scrolled to the top
 */
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navbarController scrollViewDidScrollToTop:scrollView];
}

/**
 * @method checkForLoad
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



#pragma mark - TableView Events
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
 * 10 : (UIImageView *)     Results Mark
 * 100: (UILabel *)         Outcome label
 * 101: (UIImageView *)     Champion icon
 * 102: (UILabel *)         Champion name label
 * 103: (UIImageView *)     Summoner spell 1 icon
 * 104: (UIImageView *)     Summoner spell 2 icon
 * 105: (UILabel *)         Score label
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* GET LABELS */
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"matchHistoryCell" forIndexPath:indexPath];

    //Match Related
    UIImageView *resultsMark            = (UIImageView *)[cell viewWithTag:100];
    UILabel     *outcome                = (UILabel     *)[cell viewWithTag:101];
    UILabel     *durationLabel          = (UILabel     *)[cell viewWithTag:102];
    UILabel     *creationLabel          = (UILabel     *)[cell viewWithTag:103];
    
    //Champion Related
    UIImageView *championImageView      = (UIImageView *)[cell viewWithTag:200];
    UILabel     *championName           = (UILabel     *)[cell viewWithTag:201];
    UIImageView *summonerIcon1ImageView = (UIImageView *)[cell viewWithTag:202];
    UIImageView *summonerIcon2ImageView = (UIImageView *)[cell viewWithTag:203];
    
    //Score Related
    UILabel     *scoreLabel             = (UILabel     *)[cell viewWithTag:300];
    UILabel     *kdaLabel               = (UILabel     *)[cell viewWithTag:301];
    UILabel     *multiKillLabel         = (UILabel     *)[cell viewWithTag:302];
    
    //Stat Related
    UILabel     *levelLabel             = (UILabel     *)[cell viewWithTag:400];
    UILabel     *creepLabel             = (UILabel     *)[cell viewWithTag:401];
    UILabel     *goldLabel              = (UILabel     *)[cell viewWithTag:402];
    UILabel     *wardLabel              = (UILabel     *)[cell viewWithTag:403];
    
    //Item Related
    UIImageView *item0ImageView = (UIImageView *)[cell viewWithTag:600];
    UIImageView *item1ImageView = (UIImageView *)[cell viewWithTag:601];
    UIImageView *item2ImageView = (UIImageView *)[cell viewWithTag:602];
    UIImageView *item3ImageView = (UIImageView *)[cell viewWithTag:603];
    UIImageView *item4ImageView = (UIImageView *)[cell viewWithTag:604];
    UIImageView *item5ImageView = (UIImageView *)[cell viewWithTag:605];
    UIImageView *item6ImageView = (UIImageView *)[cell viewWithTag:606];


    /* GET STATIC DATA */
    TAPDataManager *dataManager = [TAPDataManager sharedManager];
    NSDictionary *match = self.matches[indexPath.row];
    int summonerIndex = [match[@"summonerIndex"] intValue];
    NSDictionary *info  = match[@"participants"][summonerIndex];
    NSDictionary *stats = info[@"stats"];
    

    /* SET LABELS */
    //Result labels
    if ([stats[@"winner"] boolValue])
    {
        outcome.text = @"Victory";
        outcome.textColor = [UIColor colorWithRed:(145.f/255.f) green:(200.f/255.f) blue:(92.f/255.f) alpha:1];
        //outcome.textColor = [UIColor colorWithRed:0 green:0.4 blue:0 alpha:1];
    }
    else
    {
        outcome.text = @"Defeat";
        outcome.textColor = [UIColor colorWithRed:1.f green:(97.f/255.f) blue:(63.f/255.f) alpha:1];
        //outcome.textColor = [UIColor redColor];
    }
    resultsMark.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@ Mark.png", outcome.text]];
    
    //duration
    long duration = [match[@"matchDuration"] longValue];
    int min = (int)(duration / 60);
    int sec = (int)(duration % 60);
    NSString *durationFormat = (sec > 10) ? @"%d:%d" : @"%d:0%d";
    [durationLabel setText: [NSString stringWithFormat:durationFormat, min, sec]];
    
    //time
    long creation = [match[@"matchCreation"] longValue]/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:creation];
    NSLog(@"%@", date);
    [creationLabel setText:getTimeAgoWith(date)];
    
    
    //Champion labels
    NSString *champion = dataManager.champions[ [info[@"championId"] stringValue] ][@"key"];
    NSString *champName = dataManager.champions[ [info[@"championId"] stringValue] ][@"name"];
    [championName setText: champName];//[champName uppercaseString]];
    [championImageView setBorderWidth:2.0f color:[UIColor blackColor]];
    [championImageView setBorderRadius: CGRectGetWidth(championImageView.frame)/2];
    [championImageView setImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", champion]]];
    
    NSString *spell1   = dataManager.summonerSpells[ [info[@"spell1Id"] stringValue] ][@"key"];
    NSString *spell2   = dataManager.summonerSpells[ [info[@"spell2Id"] stringValue] ][@"key"];
    [summonerIcon1ImageView setImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", spell1]]];
    [summonerIcon2ImageView setImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", spell2]]];
    [summonerIcon1ImageView setBorderRadius:3.0f];
    [summonerIcon2ImageView setBorderRadius:3.0f];

    //Score labels
    NSNumber *kills   = stats[@"kills"];
    NSNumber *deaths  = stats[@"deaths"];
    NSNumber *assists = stats[@"assists"];
    float kdaStat = ([kills floatValue] + [assists floatValue]) / [deaths floatValue];
    [scoreLabel setText: [NSString stringWithFormat:@"%@/%@/%@", kills, deaths, assists]];
    [kdaLabel   setText: [NSString stringWithFormat:@"%.2f KDA", kdaStat]];
    
    //Stat labels
    int gold = (int)[stats[@"goldEarned"] longValue]/1000;
    int wards  = stats[@"wardsPlaced"] ? [stats[@"wardsPlaced"] intValue] : 0;
    [levelLabel setText: [NSString stringWithFormat:@"%@", stats[@"champLevel"]]];
    [creepLabel setText: [NSString stringWithFormat:@"%@", stats[@"minionsKilled"]]];
    [goldLabel  setText: [NSString stringWithFormat:@"%dk", gold]];
    [wardLabel  setText: [NSString stringWithFormat:@"%d", wards]];
    
    //Multikill
    int multikill = [stats[@"largestMultiKill"] intValue];
    NSString *multikillString;
    if (multikill == 5) multikillString = @"Penta Kill";
    if (multikill == 4) multikillString = @"Quadra Kill";
    if (multikill == 3) multikillString = @"Triple Kill";
    if (multikill == 2) multikillString = @"Double Kill";
    [multiKillLabel setText: multikillString];
    

    //Item icons
    NSArray *itemImageViews = @[item0ImageView, item1ImageView, item2ImageView, item3ImageView, item4ImageView, item5ImageView, item6ImageView];
    NSArray *items = @[stats[@"item0"], stats[@"item1"], stats[@"item2"], stats[@"item3"], stats[@"item4"], stats[@"item5"], stats[@"item6"]];
    for (int i = 0; i < itemImageViews.count; i++)
    {
        NSString *itemKey = [items[i] stringValue];
        if ([itemKey isEqualToString:@"0"]) itemKey = @"0000";

        UIImageView *itemView = (UIImageView *)itemImageViews[i];
        [itemView setBorderRadius:4.0f];
        [itemView setBorderWidth:0.5f color:[UIColor whiteColor]];
        [itemView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", itemKey]]];
    }

    // debug
    //UILabel *matchNumberLabel = (UILabel *)[cell viewWithTag:200];
    //matchNumberLabel.text = [[NSNumber numberWithInteger:(indexPath.row + 1)] stringValue];
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
    [self searchSummonerWithName:self.searchField.text region:self.searchField.selectedRegion];
    
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
    [TAPDataManager getSummonerForName:name region:region
    successHandler:^(NSDictionary *summoner)
    {
        //revert this search field back to this summoner's name
        self.searchField.text = self.summonerInfo[@"name"];
    
        TAPSummonerViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"summonerVC"];
        nextVC.summonerInfo = summoner;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    failureHandler:^(NSString *errorMessage)
    {
        [self showAlertWithTitle:@"Error" message:errorMessage];
    }];
}

@end
