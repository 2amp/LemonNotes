
#import "TAPSignInViewController.h"
#import "TAPStartGameViewController.h"
#import "TAPRootViewController.h"
#import "DataManager.h"
#import "Constants.h"


@interface TAPSignInViewController ()

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
    self.summonerName = self.signInField.text;
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
    NSURLSessionDataTask *getSummonerInfo = [self.urlSession dataTaskWithURL:apiURL(kLoLSummonerByName, @"na", self.summonerName, @"")
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ( httpResponse.statusCode == 404 )
        {
            [self showAlertWithTitle:@"Login Error" message:@"Summoner not found"];
        }
        else
        {
            NSDictionary *summonerInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][self.summonerName];
            //[DataManager sharedManager].currentSummonerInfo = summonerInfo;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:summonerInfo[@"id"]   forKey:@"currentSummonerId"];
            [defaults setObject:summonerInfo[@"name"] forKey:@"currentSummonerName"];
            
            NSLog(@"stop");
            [self.activityIndicator stopAnimating];
            //[self performSegueWithIdentifier:@"showRoot" sender:self];
        }
    }];
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
