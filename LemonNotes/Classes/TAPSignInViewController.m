
#import "TAPSignInViewController.h"
#import "TAPRootViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "TAPSearchField.h"
#import "DataManager.h"
#import "Constants.h"


@interface TAPSignInViewController ()

//UI
@property (nonatomic, weak) IBOutlet TAPSearchField *signInField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

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

    NSLog(@"%@ %p", self.class, self);
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
    self.summonerName = self.signInField.text;
    self.summonerRegion = self.signInField.selectedRegion;
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

            NSLog(@"%@", summonerInfo[@"profileIconId"]);
            //register this summoner
            DataManager *manager = [DataManager sharedManager];
            [manager registerSummoner];
            [manager loadRecentMatches];
            //[manager summonerDump];

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
