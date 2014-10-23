#import "TAPSignInViewController.h"
#import "TAPStartGameViewController.h"
#import "Constants.h"
#import "apikeys.h"

@interface TAPSignInViewController ()

@end

@implementation TAPSignInViewController

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



/* ========== (START) Controller Event Callbacks ============================ */

/**
 * Method: signIn
 * Usage: called when user taps "Sign In"
 * --------------------------
 * Sets whatever is entered in signInField as summonerName.
 * If nothing is entered, shows a login error prompting the user to enter a
 * summoner name. Otherwise, makes the summoner name info API call. 
 * If the entered summoner name was not found, display an error. Otherwise,
 * segue to the start game view controller with the provided summoner info. 
 */
- (IBAction)signIn:(id)sender
{
	self.summonerName = self.signInField.text;

	if ([self.summonerName isEqual: @""])
    {
		[self showAlertWithTitle:@"Error" message:@"Please enter a summoner name."];
    }
	else
	{
		NSString *requestString = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=%@",
                                   self.summonerName, API_KEY];
        NSURL *url = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (!error)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                // Make sure to only do GUI updates on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
                if (httpResponse.statusCode != 404)
                {
                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    NSError* jsonParsingError = nil;
                    NSDictionary* summonerInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                    if (jsonParsingError)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
                        });
                    }
                    else
                    {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self showAlertWithTitle:self.summonerName
//                                             message:[NSString stringWithFormat:@"Level: %@", summonerInfo[self.summonerName][@"summonerLevel"]]];
//                        });
                        self.idNumber = summonerInfo[self.summonerName][@"id"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"showStartGame" sender:self];
                        });
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlertWithTitle:@"Error" message:@"The summoner name you entered was not found."];
                    });
                }

            }
            else
            {
                NSLog(@"There was an error with the API call!");
            }
        };
        NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:url completionHandler:completionHandler];
        [dataTask resume];
        [self.activityIndicator startAnimating];
	}
}

/* ========== (END) Controller Event Callbacks ============================== */

/* ========== (START) View Alert Methods ============================== */

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

/* ========== (END) View Alert Methods ============================== */

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
