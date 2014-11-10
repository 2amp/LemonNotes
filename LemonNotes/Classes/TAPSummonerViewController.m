
#import "TAPSummonerViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "DataManager.h"
#import "Constants.h"



@interface TAPSummonerViewController()

//Nav bar
@property (nonatomic, weak) IBOutlet UITextField* searchField;
@property (nonatomic, strong) UIBarButtonItem* regionButton;
@property (nonatomic, strong) UIPickerView* regionPicker;
@property (nonatomic, strong) UITextField* pickerWrapper;
@property (nonatomic, strong) NSString* selectedRegion;
- (IBAction)selectRegion:(id)sender;

//Header
@property (nonatomic) NSDictionary *summoner;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerLevelLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;
@property (nonatomic, weak) IBOutlet UIImageView* championSplashView;

//setup
- (void)setupNavBar;
- (void)setupHeader;

@end



@implementation TAPSummonerViewController

#pragma mark View Messages
/**
 * @method viewDidLoad
 *
 * Called once when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"TAPSummonerViewController viewDidLoad %p", &self);
    
    //if rootVC of nav
    if (self == [self.navigationController.viewControllers firstObject])
    {
        self.summoner = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
        self.summonerName = self.summoner[@"name"];
    }
    [self setupNavBar];
    [self setupHeader];
}

/**
 * @method setupNavBar
 *
 * Setups the nav bar components
 */
- (void)setupNavBar
{
    //set ref. to right bar button
    self.regionButton = self.navigationItem.rightBarButtonItem;
    
    //search field
    UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnifying_glass.png"]];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    searchIcon.tintColor = [UIColor whiteColor];
    self.searchField.leftView = searchIcon;
    self.searchField.leftView.frame = CGRectMake(10, 0, 15, 15);
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    
    //default region to NA
    self.selectedRegion = self.summoner[@"region"];
    self.regionButton.title = [self.selectedRegion uppercaseString];
    
    //make an internal picker view
    self.regionPicker = [[UIPickerView alloc] init];
    self.regionPicker.delegate = self;
    self.regionPicker.dataSource = [DataManager sharedManager];
    self.regionPicker.backgroundColor = [UIColor whiteColor];
    [self.regionPicker selectRow:[[DataManager sharedManager].regions indexOfObject:self.selectedRegion] inComponent:0 animated:NO];
    
    //make a dummy text field that contains the picker view as a inputView
    //showing picker view simplified to making this dummy first responder
    self.pickerWrapper = [[UITextField alloc] initWithFrame:CGRectMake(0,0,0,0)];
    self.pickerWrapper.inputView = self.regionPicker;
    [self.view addSubview:self.pickerWrapper];
}

/**
 * @method setupHeader
 *
 * Setups the header components
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


#pragma mark - IBActions
/**
 * @method selectRegion
 *
 * Called when user taps region button.
 * Makes picker view available if not already.
 * Otherwise dismisses it.
 */
- (IBAction)selectRegion:(id)sender
{
    if ([self.pickerWrapper isFirstResponder])
    {
        [self.pickerWrapper resignFirstResponder];
    }
    else
    {
        [self.pickerWrapper becomeFirstResponder];
    }
}



#pragma mark - Region Picker Delegate
/**
 * @method pickerView:titleForRow:forComponent
 *
 * Sets title of the row as the region in caps
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[DataManager sharedManager].regions[row] uppercaseString];
}

/**
 * @method pickerView:didSelectRow:inComponent
 *
 * When a certain row is selected,
 * the region is set as summoner's region and button's title is updated
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.pickerWrapper resignFirstResponder];
    
    self.selectedRegion = [DataManager sharedManager].regions[row];
    self.regionButton.title = [self.selectedRegion uppercaseString];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showNextViewController" sender:self];
}

#pragma mark - Navigation Events
/**
 * Currently no segue from the main vc occurs. Will soon change!
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end