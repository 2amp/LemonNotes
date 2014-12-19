
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
    //start rolling
    [self.activityIndicator startAnimating];

    //async search/fetch summoner
    [DataManager getSummonerForName:self.summonerName
                             region:self.summonerRegion
                     successHandler:^(NSDictionary *summoner) {
                         [self.activityIndicator stopAnimating];
                         NSLog(@"summoner %@", summoner);
                         [[NSUserDefaults standardUserDefaults] setObject:summoner forKey:@"currentSummoner"];
                         [self performSegueWithIdentifier:@"showRoot" sender:self];
                     }
                     failureHandler:^(NSString *errorMessage) {
                         [self.activityIndicator stopAnimating];
                         [self showAlertWithTitle:@"Error" message:errorMessage];
                     }];
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
