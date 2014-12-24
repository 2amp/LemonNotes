
#import "TAPScrollNavBarController.h"


@interface TAPScrollNavBarController()
{
    
}

@property (nonatomic, weak) UINavigationBar *navbar;

@end
#pragma mark -



@implementation TAPScrollNavBarController

#pragma mark Init
/**
 * @method initWithNavBar
 *
 *
 */
- (instancetype)initWithNavBar:(UINavigationBar *)navbar
{
    if (self = [super init])
    {
        self.navbar = navbar;
    }
    return self;
}


#pragma mark - Scroll View Delegate
/**
 * @method scrollViewWillBeginDragging
 *
 * Called when user is about to start dragging.
 * Set and store height of navbar before drag starts.
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

/**
 * @method scrollViewDidScroll
 *
 * Called when user is scrolling.
 * Caclulate and recognize any necessary events.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

/**
 * @method scrollViewDidEndDragging:willDecelerate:
 *
 * Called when user has lifted his finger,
 * and view might still move due to velocity.
 *
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}


#pragma mark - NavBar Control


@end
