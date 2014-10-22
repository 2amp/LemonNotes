
#import "TAPSignInViewController.h"
#import "Constants.h"
#import "apikeys.h"

@interface TAPSignInViewController ()

@property (nonatomic) NSString* summonerName;

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



/* ========== Controller Event Callbacks ============================== */

/**
 * Method: signIn
 * Usage: called when user taps "Sign In"
 * --------------------------
 * Sets whatever is entered in signInField as summonerName.
 * If nothing is entered, shows a login error prompting the user to enter a 
 * summoner name. Otherwise, makes the summoner name info API call.
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSError* jsonParsingError = nil;
                NSDictionary* summonerInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                if (jsonParsingError)
                {
                    // Make sure to only do GUI updates on the main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlertWithTitle:self.summonerName
                                         message:[NSString stringWithFormat:@"Level: %@", summonerInfo[self.summonerName][@"summonerLevel"]]];
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



/* ========== View Alert Methods ============================== */

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

@end
