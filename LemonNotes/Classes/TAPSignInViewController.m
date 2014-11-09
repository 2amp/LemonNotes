
#import "TAPSignInViewController.h"
#import "TAPRootViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "DataManager.h"
#import "Constants.h"


@interface TAPSignInViewController ()

//UI
@property (nonatomic, weak) IBOutlet UITextField *signInField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton* regionButton;
@property (nonatomic, strong) UIPickerView* regionPicker;
@property (nonatomic, strong) UITextField* pickerWrapper;
- (IBAction)selectRegion:(id)sender;

//Private
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSString *summonerName;
@property (nonatomic, strong) NSString *summonerRegion;
- (void)signIn;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end



@implementation TAPSignInViewController

#pragma mark View Messages
/**
 * @method viewDidLoad
 * 
 * Called when view is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:config];
    
    //default region to NA
    self.summonerRegion = @"na";
    [self.regionButton setTitle:[self.summonerRegion uppercaseString] forState:UIControlStateNormal];
    
    //make an internal picker view
    self.regionPicker = [[UIPickerView alloc] init];
    self.regionPicker.delegate = self;
    self.regionPicker.dataSource = self;
    self.regionPicker.backgroundColor = [UIColor whiteColor];
    [self.regionPicker selectRow:[[DataManager sharedManager].regions indexOfObject:self.summonerRegion] inComponent:0 animated:NO];
    
    //make a dummy text field that contains the picker view as a inputView
    //showing picker view simplified to making this dummy first responder
    self.pickerWrapper = [[UITextField alloc] initWithFrame:CGRectMake(0,0,0,0)];
    self.pickerWrapper.inputView = self.regionPicker;
    [self.view addSubview:self.pickerWrapper];
}

/**
 * @method viewWillAppear:
 *
 * If a successful summoner search was previously made, set the sign in field 
 * text to the last summoner name that was searched.
 * Initializes an NSURLSession instance for data requests.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/**
 * @method didReceiveMemoryWarning
 *
 * Called when VC receives memory warning
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



#pragma mark - Controller Event Callbacks
/**
 * @method selectRegion:
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

/**
 * @method textFieldShouldReturn
 *
 * Called when user taps "Done" on textField.
 * Sets summonerName as entered text. 
 * Removes keyboard with resignFirstResponder and calls signIn.
 *
 * @param textField textField with enetered summonerName
 * @return YES to implement default textField behavior
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.summonerName = textField.text;
    [textField resignFirstResponder];
    [self signIn];
    
    return YES;
}

/**
 * @method signIn
 *
 * Makes the summoner name info API call.
 * If the entered summoner name was not found, display an error. 
 * Otherwise, segue to the start game view controller with the provided summoner info.
 * In addition, add the summoner name and ID numbers to the standard user defaults.
 */
- (void)signIn
{
    [self.activityIndicator startAnimating];
    void (^completionHandler)(NSData *data, NSURLResponse *, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 404)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self showAlertWithTitle:@"Error" message:@"Summoner not found"];
            });
        }
        else
        {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

            // it is not guaranteed that the key for the summoner info object is the summoner name
            NSMutableDictionary *summonerInfo = [NSMutableDictionary dictionaryWithDictionary:dataDictionary[[dataDictionary allKeys][0]]];
            [summonerInfo setObject:self.summonerRegion forKey:@"region"];
            [[NSUserDefaults standardUserDefaults] setObject:[summonerInfo copy] forKey:@"currentSummoner"];

            //register this summoner
            DataManager *manager = [DataManager sharedManager];
            [manager registerSummoner];
            [manager loadRecentMatches];
            [manager summonerDump];

            //stop loading spin & show root
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"showRoot" sender:self];
            });
        }
    };
    NSURLSessionDataTask *getSummonerInfo = [self.urlSession dataTaskWithURL:apiURL(kLoLSummonerByName, self.summonerRegion, self.summonerName, nil)
                                                           completionHandler:completionHandler];
    [getSummonerInfo resume];
    [self.activityIndicator startAnimating];
}



#pragma mark - UIPicker Methods
/**
 * @method numberOfComponentsInPickerView
 *
 * Only 1 column of regions
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 * @method pickerView:numberRowsInComponent
 *
 * Returns number of regions defined in DataManager
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[DataManager sharedManager].regions count];
}

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

    self.summonerRegion = [DataManager sharedManager].regions[row];
    [self.regionButton setTitle:[self.summonerRegion uppercaseString] forState:UIControlStateNormal];
}


#pragma mark - Alert Methods
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



#pragma mark - Navigation Events
/**
 * @method prepareForSegue:sender:
 *
 * Automatically called when performing a segue to the next view controller.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
