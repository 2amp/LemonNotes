
#import "TAPMainViewController.h"
#import "TAPMatchHistoryTableViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "Constants.h"



@interface TAPMainViewController()

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerRankLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;

- (IBAction)update:(id)sender;

@end



@implementation TAPMainViewController

#pragma mark - View Messages
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        
    }
    return self;
}

/**
 * @method viewDidLoad
 *
 * Called when view
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self update:self];
}

#pragma mark - Private methods
/**
 * @method updateSummonerInfo
 *
 *
 */
- (IBAction)update:(id)sender
{
    NSString *summonerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerId"];
    NSLog(@"summonerId: %@", summonerId);
    
    void (^summonerInfoHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.summonerInfo = jsonData[[jsonData allKeys][0]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *iconPath = [NSString stringWithFormat:@"%@.png", [self.summonerInfo objectForKey:@"profileIconId"]];
            self.summonerIconView.image = [UIImage imageNamed:iconPath scaledToWidth:100 height:100];
            self.summonerNameLabel.text = [self.summonerInfo objectForKey:@"name"];
            self.summonerRankLabel.text = [NSString stringWithFormat:@"Level %@", [self.summonerInfo objectForKey:@"summonerLevel"]];
        });
    };
    
    NSURLSessionDataTask *summonerInfoDataTask = [[NSURLSession sharedSession] dataTaskWithURL:apiURL(kLoLSummoner, @"na", summonerId)
                                                                             completionHandler:summonerInfoHandler];
    [summonerInfoDataTask resume];
}

#pragma mark - IBActions
/**
 * When the matches button is tapped, segue to the tab bar vc.
 */
- (IBAction)matchesTapped:(id)sender
{
    [self performSegueWithIdentifier:@"showTabBar" sender:self];
}

#pragma mark - Navigation Events
/**
 * Before seguing to the tab bar vc, pass recently played games to match history
 * vc.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTabBar"])
    {
        UITabBarController *tabBarController = segue.destinationViewController;
        TAPMatchHistoryTableViewController *matchHistoryVC = tabBarController.viewControllers[1];
        matchHistoryVC.recentGames = self.recentGames;
    }
}

@end
