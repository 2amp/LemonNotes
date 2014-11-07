
#import "TAPSignInViewController.h"
#import "TAPRootViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "DataManager.h"
#import "Constants.h"


@interface TAPSignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *signInField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSURLSession *urlSession;

- (void)signInWithSummoner:(NSString *)summonerName;
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
    [textField resignFirstResponder];
    [self signInWithSummoner:self.signInField.text];
    
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
- (void)signInWithSummoner:(NSString *)summonerName
{
    [self.activityIndicator startAnimating];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSURL *url = apiURL(kLoLSummonerByName, @"na", summonerName, @"");
    NSData *data = [NSURLSession sendSynchronousDataTaskWithURL:url returningResponse:&response error:&error];
    
    if (response.statusCode == 404)
    {
        [self.activityIndicator startAnimating];
        [self showAlertWithTitle:@"Error" message:@"Summoner not found"];
    }
    else
    {
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSMutableDictionary *summonerInfo = [dataDictionary[summonerName] mutableCopy];
        [summonerInfo setObject:@"na" forKey:@"region"];
        [[NSUserDefaults standardUserDefaults] setObject:[summonerInfo copy] forKey:@"currentSummoner"];

        //register this summoner
        DataManager *manager = [DataManager sharedManager];
        [manager registerSummoner];
        [manager loadRecentMatches];

        //stop loading spin & show root
        [self.activityIndicator stopAnimating];
        [self performSegueWithIdentifier:@"showRoot" sender:self];
    }
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
