
#import "TAPSignInViewController.h"

#import "NSURLSession+SynchronousTask.h"
#import "Reachability.h"
#import "TAPDataManager.h"
#import "TAPUtil.h"

#import "TAPBannerManager.h"
#import "TAPSearchField.h"


@interface TAPSignInViewController ()

//UI
@property (nonatomic, weak) IBOutlet TAPSearchField *signInField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

//Private
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSDictionary *summonerInfo;
- (void)signInWithName:(NSString *)name region:(NSString *)region;

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
    
    self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    self.summonerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"];
    if (self.summonerInfo != nil)
    {
        self.signInField.text = self.summonerInfo[@"name"];
        [self performSegueWithIdentifier:@"showTabBarController" sender:self];
    }
    else
    {
        if (![self.reachability isReachable])
            [[TAPBannerManager sharedManager] addBannerToTopOfView:self.view withType:BannerTypeIncomplete text:@"No Internet Connection" delay:0.5];
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
    [textField resignFirstResponder];
    
    TAPBannerManager *bm = [TAPBannerManager sharedManager];
    if (![self.reachability isReachable])
    {
        [bm addBannerToBottomOfView:self.view withType:BannerTypeIncomplete text:@"No Internet Connection." delay:0];
    }
    else if ([self.reachability isReachableViaWiFi])
    {
        [[TAPDataManager sharedManager] updateDataWithRegion:self.signInField.selectedRegion
        completionHandler:^(NSError *error)
        {
            if (!error)
                [self signInWithName:self.signInField.text region:self.signInField.selectedRegion];
        }];
    }
    else if ([self.reachability isReachableViaWWAN])
    {
        [bm addBannerToTopOfView:self.view withType:BannerTypeWarning text:@"On 3G/LTE. Tap to Continue." delay:0
        tapHandler:^()
        {
            [[TAPDataManager sharedManager] updateDataWithRegion:self.signInField.selectedRegion
            completionHandler:^(NSError *error)
            {
                if (!error)
                    [self signInWithName:self.signInField.text region:self.signInField.selectedRegion];
            }];
        }
        cancelHandler:NULL];
    }
    
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
- (void)signInWithName:(NSString *)name region:(NSString *)region
{
    //start rolling
    [self.activityIndicator startAnimating];

    //async search/fetch summoner
    [[TAPDataManager sharedManager] getSummonerForName:name region:region
     successHandler:^(NSDictionary *summoner)
     {
         [self.activityIndicator stopAnimating];
         
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
