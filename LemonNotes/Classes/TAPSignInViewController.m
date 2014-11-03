
#import "TAPSignInViewController.h"
#import "TAPStartGameViewController.h"
#import "TAPMainViewController.h"
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
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
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
    // Completion handler for recentGamesDataTask
    void (^recentGamesCompletionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            NSError* jsonParsingError = nil;
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
                // for some reason matchhistory gives matches from oldest to most recent,
                // so reverse the recentGames array to prepare for display on table view
                // in TAPMatchHistoryViewController
                self.recentGames = [[recentGames[@"matches"] reverseObjectEnumerator] allObjects];
                for (NSDictionary *match in recentGames[@"matches"])
                {
                    NSLog(@"%@", match[@"participants"][0][@"championId"]);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self performSegueWithIdentifier:@"showMain" sender:self];
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
                    // Once we have verified that the entered summoner name is valid, add it to
                    // [NSUserDefaults standardUserDefaults].
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:self.summonerName forKey:@"summonerName"];
                    self.summonerId = summonerInfo[[summonerInfo allKeys][0]][@"id"];
                    [defaults setObject:self.summonerId forKey:@"summonerId"];
                    [defaults synchronize];
                    
                    
                    NSURLSessionDataTask *recentGamesDataTask = [self.urlSession dataTaskWithURL:apiURL(kLoLMatchHistory, @"na",
                                                                                [NSString stringWithFormat:@"%@", self.summonerId])
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

    NSURLSessionDataTask *summonerInfoDataTask = [self.urlSession dataTaskWithURL:apiURL(kLoLSummonerByName, @"na", self.summonerName)
                                                                completionHandler:summonerInfoCompletionHandler];
    [summonerInfoDataTask resume];
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
 * Sets up the main view controller with an array containing the summoner's 
 * recently played games.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMain"])
    {
        TAPMainViewController *mainVC = segue.destinationViewController;
        mainVC.recentGames = self.recentGames;
    }
}

@end
