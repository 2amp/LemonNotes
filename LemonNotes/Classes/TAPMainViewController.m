
#import "TAPMainViewController.h"
#import "UIImage+UIImageAdditions.h"
#import "Constants.h"



@interface TAPMainViewController()

@property (nonatomic) NSDictionary *summonerInfo;
@property (nonatomic, weak) IBOutlet UILabel* summonerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel* summonerRankLabel;
@property (nonatomic, weak) IBOutlet UIImageView* summonerIconView;

- (void)updateSummonerInfo;

@end



@implementation TAPMainViewController

#pragma mark View Messages

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self updateSummonerInfo];
        
        NSString *iconPath = [NSString stringWithFormat:@"%@.png", [self.summonerInfo objectForKey:@"profileIconId"]];
        self.summonerIconView.image = [UIImage imageNamed:iconPath scaledToWidth:100 height:100];
        self.summonerNameLabel.text = (NSString *)[self.summonerInfo objectForKey:@"name"];
        self.summonerRankLabel.text = [NSString stringWithFormat:@"Level %@", [self.summonerInfo objectForKey:@"summonerLevel"]];
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
}



#pragma mark - Private methods
/**
 * @method updateSummonerInfo
 *
 *
 */
- (void)updateSummonerInfo
{
    NSString *summonerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerId"];
    NSLog(@"summonerId: %@", summonerId);
    
    void (^summonerInfoHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        self.summonerInfo = jsonData[ [jsonData allKeys][0] ];
        NSLog(@"%@", [self.summonerInfo objectForKey:@"name"]);
    };
    
    NSURLSessionDataTask *summonerInfoDataTask = [[NSURLSession sharedSession]
                                                  dataTaskWithURL:apiURL(kLoLSummoner, @"na", summonerId)
                                                completionHandler:summonerInfoHandler];
    [summonerInfoDataTask resume];
}



#pragma mark - Navigation Events


@end
