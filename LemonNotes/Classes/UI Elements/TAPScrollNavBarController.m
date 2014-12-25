
#import "TAPScrollNavBarController.h"
#import <objc/runtime.h>


@interface TAPScrollNavBarController()
{
    CGFloat startingY;
    CGFloat startingOffset;
    CGFloat previousOffset;
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
        startingY = navbar.frame.origin.y;
        startingOffset = -CGRectGetMaxY(navbar.frame);
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
    previousOffset = scrollView.contentOffset.y;
    
    NSLog(@"y: %f, height: %f", self.navbar.frame.origin.y, self.navbar.frame.size.height);
}

/**
 * @method scrollViewDidScroll
 *
 * Called when user is scrolling.
 * Caclulate and recognize any necessary events.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat delta = previousOffset - currentOffset;
    previousOffset = currentOffset;
    
    if (currentOffset > startingOffset && [self validDelta:delta])
    {
        [self scrollNavbarWithDelta:delta];
    }
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
/**
 * @method scrollNavbarWithDelta:
 *
 * Given a delta value which the user scrolled,
 * scrolls the navbar by the same delta if possible.
 * 
 * @param  delta value of user's scroll
 */
- (void)scrollNavbarWithDelta:(CGFloat)delta
{
    CGRect frame = self.navbar.frame;
    frame.origin.y += delta;
    self.navbar.frame = frame;
}


#pragma mark - Helper Methods
/**
 * @method validDelta
 *
 * Determines whether navbar can move the given delta
 */
- (BOOL)validDelta:(CGFloat)delta
{
    CGRect frame = self.navbar.frame;
    CGFloat dest = frame.origin.y + delta;
    
    return (startingY - frame.size.height < dest) && (dest < startingY);
}

@end
