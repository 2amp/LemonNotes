
#import "TAPSignInViewController.h"
#import "TAPStartGameViewController.h"
#import "Constants.h"
#import "apikeys.h"



@interface TAPSignInViewController ()

@end



@implementation TAPSignInViewController

#pragma mark View Messages
/**
 * Method: viewDidLoad
 * Usage: called when view is loaded
 * --------------------------
 * Initializes an NSURLSession instance for data requests.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:config];
}

/**
 * Method: didReceiveMemoryWarning
 * Usage: called when memory warning is fired
 * --------------------------
 *
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -



#pragma mark Controller Event Callbacks
/**
 * Method: textFieldShouldReturn
 * Usag: called when user taps "Done" on textField
 * --------------------------
 * Sets summonerName as enetered text and resets text.
 * Removes keyboard with resignFirstResponder.
 * Manually calls signIn with textField as sender.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.summonerName = self.signInField.text;
    self.signInField.text = @"";
    [textField resignFirstResponder];
    
    [self signIn:textField];
    
    return YES;
}

/**
 * Method: signIn
 * Usage: called when user taps "Sign In"
 * --------------------------
 * If nothing is entered, shows a login error prompting the user to enter a
 * summoner name. Otherwise, makes the summoner name info API call. 
 * If the entered summoner name was not found, display an error. Otherwise,
 * segue to the start game view controller with the provided summoner info. 
 */
- (IBAction)signIn:(id)sender
{
	if ([self.summonerName isEqual: @""])
    {
		[self showAlertWithTitle:@"Error" message:@"Please enter a summoner name."];
    }
	else
	{
        // Completion handler for recentGamesDataTask
        void (^recentGamesCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (!error)
            {
                NSError* jsonParsingError = nil;
                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary* recentGames = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                if (jsonParsingError)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        [self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
                    });
                }
                else
                {
                    NSLog(@"%@", recentGames[@"matches"]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        [self performSegueWithIdentifier:@"showStartGame" sender:self];
                    });
                }
            }
            else
            {
                NSLog(@"There was an error with the API call!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }
        };
        
        NSString *summonerInfoRequestString = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=%@",
                                               self.summonerName, API_KEY];
        NSURL *summonerInfoUrl = [NSURL URLWithString:[summonerInfoRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // Completion handler for summonerInfoDataTask
        void (^summonerInfoCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (!error)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                // Make sure to only do GUI updates on the main thread
                if (httpResponse.statusCode != 404)
                {
                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSError* jsonParsingError = nil;
                    NSDictionary* summonerInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                    if (jsonParsingError)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicator stopAnimating];
                            [self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
                        });
                    }
                    else
                    {
                        // We need to set up recentGamesDataTask in the completion handler of summonerInfoDataTask because
                        // it we need to fetch the summoner ID first. I'm not sure if this is the best way to do it, but
                        // at least it works.
                        self.idNumber = summonerInfo[[summonerInfo allKeys][0]][@"id"];
                        NSString *recentGamesRequestString = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/na/v2.2/matchhistory/%@?api_key=%@",
                                                              self.idNumber, API_KEY];
                        NSURL *recentGamesUrl = [NSURL URLWithString:[recentGamesRequestString
                                                                      stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        NSURLSessionDataTask *recentGamesDataTask = [self.urlSession dataTaskWithURL:recentGamesUrl
                                                                                   completionHandler:recentGamesCompletionHandler];
                        [recentGamesDataTask resume];
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        [self showAlertWithTitle:@"Error" message:@"The summoner name you entered was not found."];
                    });
                }

            }
            else
            {
                NSLog(@"There was an error with the API call!");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }
        };

        NSURLSessionDataTask *summonerInfoDataTask = [self.urlSession dataTaskWithURL:summonerInfoUrl completionHandler:summonerInfoCompletionHandler];
        [summonerInfoDataTask resume];
        [self.activityIndicator startAnimating];
	}
}
#pragma mark -



#pragma mark Alert Methods
/**
 * Method: showAlertWithTitle:message:
 * Usage: pop alert window on screen
 * --------------------------
 * Creates an UIAlertView object with the given title & message
 * along with self as delegate, "OK" as cancel button, and no other buttons.
 * Immediately shows the window
 *
 * @param title
 * @param message
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

/**
 * Method: alertView:willDissmissWithButtonIndex
 * Usage: called when user presses a button on UIAlertView
 * --------------------------
 * Fired when "OK" button is pressed (since there are no other buttons).
 * Rests signInField to empty string.
 *
 * @param alertView
 * @param buttonIndex - index of the pressed button on the alert windows
 */
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.signInField.text = @"";
    
}
#pragma mark -



#pragma mark Navigation Events
/**
 * Method: prepareForSegue:sender
 * Usage: Automatically called when performing a segue to the next view 
 * controller.
 * --------------------------
 * Sets up the start game view controller with the summoner name and ID number
 * that was fetched earlier.
 *
 * @param segue
 * @param sender
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showStartGame"])
    {
        TAPStartGameViewController *vc = segue.destinationViewController;
        vc.summonerName = self.summonerName;
        vc.idNumber = self.idNumber;
    }
}

@end
