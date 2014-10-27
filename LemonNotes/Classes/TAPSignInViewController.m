
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
 * Usage: called when view has loaded
 * --------------------------
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Method: viewWillAppear:
 * Usage: called when view will appear
 * --------------------------
 * Initializes an NSURLSession instance for data requests. Performs a champion
 * ID data request to populate self.championIds with a dictionary mapping each
 * champion ID to the name of the champion.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *savedSummonerName = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerName"];
    if (savedSummonerName != nil && ![savedSummonerName isEqualToString:@""])
    {
        self.signInField.text = savedSummonerName;
    }
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:config];
    NSString *championIdsRequestString = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=%@", API_KEY];
    NSURL *championIdsRequestUrl = [NSURL URLWithString:[championIdsRequestString
                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            NSError* jsonParsingError = nil;
            NSDictionary* championIdsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            if (jsonParsingError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self showAlertWithTitle:@"JSON Error" message:[jsonParsingError localizedDescription]];
                });
            }
            else
            {
                NSMutableDictionary *championIds = [NSMutableDictionary dictionaryWithDictionary:[championIdsDict objectForKey:@"data"]];
                NSArray *keys = [championIds allKeys];
                for (NSString *key in keys)
                {
                    NSDictionary *info = [championIds objectForKey:key];
                    [championIds removeObjectForKey:key];
                    [championIds setObject:info forKey:[info objectForKey:@"id"]];
                }
                self.championIds = [NSDictionary dictionaryWithDictionary:championIds];
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
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:championIdsRequestUrl completionHandler:completionHandler];
    [dataTask resume];
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



#pragma mark - Controller Event Callbacks
/**
 * Method: textFieldShouldReturn
 * Usag: called when user taps "Done" on textField
 * --------------------------
 * Sets summonerName as enetered text and resets text.
 * Removes keyboard with resignFirstResponder.
 * Manually calls signIn with textField as sender.
 *
 * @param textField
 * @return BOOL - YES to implement default textField behavior
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.summonerName = self.signInField.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.summonerName forKey:@"summonerName"];
    self.signInField.text = @"";
    [textField resignFirstResponder];

    [self signIn];

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
- (void)signIn
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
                for (NSDictionary *match in recentGames[@"matches"])
                {
                    NSLog(@"%@", match[@"participants"][0][@"championId"]);
                }
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

    NSString *summonerInfoRequestString = [NSString stringWithFormat:@"https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/%@?api_key=%@", self.summonerName, API_KEY];
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



#pragma mark - Alert Methods
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
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - Navigation Events
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
