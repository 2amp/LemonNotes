
#import "TAPSummonerNavigationController.h"



@interface TAPSummonerNavigationController()

@end



@implementation TAPSummonerNavigationController
/**
 * @method viewDidLoad
 *
 * Called when navigation controller is loaded to memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hidesBarsOnSwipe = YES;
}

/**
 * @method viewWillLoad
 *
 * Called every time before nav controller will load
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}



@end
