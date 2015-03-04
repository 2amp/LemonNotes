
#import "TAPSignInViewController.h"
#import "NSURLSession+SynchronousTask.h"
#import "TAPSearchField.h"
#import "TAPDataManager.h"
#import "TAPBannerManager.h"
#import "TAPUtil.h"


@interface TAPSignInViewController ()

//UI
@property (nonatomic, weak) IBOutlet TAPSearchField *signInField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

//Private
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSString *summonerName;
@property (nonatomic, strong) NSString *summonerRegion;
- (void)signIn;

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
    
    NSLog(@"%@ %p", self.class, self);
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:config];

    NSDictionary *summoner = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    if (summoner != nil)
    {
        [self.view setUserInteractionEnabled:NO];
        self.signInField.text = summoner[@"name"];
        
        [self.loadingIndicator startAnimating];
        [[TAPDataManager sharedManager] updateDataWithRegion:summoner[@"region"]
        completionHandler:^(NSError *error)
        {
            self.view.userInteractionEnabled = YES;
            [self.loadingIndicator stopAnimating];
            
            if (!error) [self performSegueWithIdentifier:@"showTabBarController" sender:self];
            else
            {
                [[TAPBannerManager sharedManager] addBannerToBottomOfView:self.view withType:BannerTypeError text:error.domain delay:0
                 tapHandler:NULL cancelHandler:NULL];
            }
        }];
    }
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
    NSLog(@"[SignInVC signIn]");
    
    //start rolling
    [self.activityIndicator startAnimating];

    //async search/fetch summoner
    [[TAPDataManager sharedManager] getSummonerForName:self.summonerName region:self.summonerRegion
     successHandler:^(NSDictionary *summoner)
     {
         [self.activityIndicator stopAnimating];
         if (summoner == nil)
         {
             NSLog(@"summoner %@", summoner);
         }
         [[NSUserDefaults standardUserDefaults] setObject:summoner forKey:@"currentSummoner"];
         [self performSegueWithIdentifier:@"showTabBarController" sender:self];
     }
     failureHandler:^(NSString *errorMessage)
     {
         [self.activityIndicator stopAnimating];
         [[TAPBannerManager sharedManager] addBannerToTopOfView:self.view withType:BannerTypeError text:@"Summoner Not Found" delay:0.25
          tapHandler:NULL
          cancelHandler:NULL];
     }];
}


#pragma mark - Navigation Events
/**
 * @method prepareForSegue:sender:
 *
 * Automatically called when performing a segue to the next view controller.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTabBarController"])
    {
        UITabBarController *tabBarController = (UITabBarController *)(segue.destinationViewController);
        UIStoryboard *matchHistoryStoryboard = [UIStoryboard storyboardWithName:@"MatchHistory" bundle:nil];
        UIStoryboard *gameStartStoryboard = [UIStoryboard storyboardWithName:@"StartGame" bundle:nil];
        UIStoryboard *moreStoryboard = [UIStoryboard storyboardWithName:@"More" bundle:nil];
        UINavigationController *summonerVNC = [matchHistoryStoryboard instantiateInitialViewController];
        UINavigationController *startGameVNC = [gameStartStoryboard instantiateInitialViewController];
        UINavigationController *moreVNC = [moreStoryboard instantiateInitialViewController];
        tabBarController.viewControllers = @[summonerVNC, startGameVNC, moreVNC];
    }
}

@end
