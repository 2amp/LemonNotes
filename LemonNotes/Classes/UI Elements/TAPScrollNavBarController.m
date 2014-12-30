
#import "TAPScrollNavBarController.h"
#import <objc/runtime.h>



@interface TAPScrollNavBarController()
{
    CGFloat navbarHeight;
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
        navbarHeight = navbar.frame.size.height;
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
 *
 * @param scrollView - that will begin scrolling
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    previousOffset = scrollView.contentOffset.y;
    
    //NSLog(@"y: %f, height: %f", self.navbar.frame.origin.y, self.navbar.frame.size.height);
}

/**
 * @method scrollViewDidScroll
 *
 * Called when user is scrolling.
 * Caclulate and recognize any necessary events.
 *
 * @param scrollView - that is currently scrolling
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat delta = [self validDelta:(previousOffset - currentOffset)];
    previousOffset = currentOffset;

    if ([self isValidOffset:currentOffset])
    {
        //NSLog(@"offset: %f", currentOffset);
        [self scrollNavbarWithDelta:delta];
        [self adjustScrollView:scrollView toDelta:delta];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    CGFloat navbarMaxY = [self statusbarHeight] + navbarHeight;
    [scrollView setContentOffset:(CGPoint){0, -navbarMaxY} animated:NO];
}

/**
 * @method scrollViewDidEndDragging:willDecelerate:
 *
 * Called when user has lifted his finger,
 * and view might still move due to velocity.
 *
 * @param scrollView - dragging ended on
 * @param decelerate - whether scrollView will slow down
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self preventPartialScroll:scrollView];
}


#pragma mark - NavBar Control
/**
 * @method scrollNavbarWithDelta:
 *
 * Given a delta value which the user scrolled,
 * scrolls the navbar by the same delta if possible.
 * 
 * @param delta - value of user's scroll
 */
- (void)scrollNavbarWithDelta:(CGFloat)delta
{
    CGRect frame = self.navbar.frame;
    frame.origin.y += delta;
    self.navbar.frame = frame;
}

/**
 * @method adjustScrollView:toDelta:
 *
 * Given a scroll view and a delta,
 * adjusts the inset by the given delta to give
 * the illusion of scrolling as navbar scrolls
 *
 * @param scrollView - to adjust
 * @param delta      - to adjust by
 */
- (void)adjustScrollView:(UIScrollView *)scrollView toDelta:(CGFloat)delta
{
    UIEdgeInsets insets = scrollView.contentInset;
    insets.top += delta;
    scrollView.contentInset = insets;
    scrollView.scrollIndicatorInsets = insets;
}

/**
 * @method preventPartialScroll:
 *
 * If the lower edge of navbar is smaller than fully expanded,
 * animate both navbar & scrollView to collapse.
 *
 * @param scrollView - to prevent partial scrolling
 */
- (void)preventPartialScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.navbar.frame;
    
    if (CGRectGetMaxY(frame) < [self statusbarHeight] + navbarHeight)
    {
        CGFloat deltaToStatusBar = [self statusbarHeight] - CGRectGetMaxY(frame);
        
        [UIView animateWithDuration:0.1 animations:
        ^{
            [self scrollNavbarWithDelta:deltaToStatusBar];
            [self adjustScrollView:scrollView toDelta:deltaToStatusBar];
        }];
    }
}


#pragma mark - Helper Methods
/**
 * @method statusBarHeight
 *
 * Gives the status bar height according to orientation & visibility
 * @return CGFloat of status bar height
 */
- (CGFloat)statusbarHeight
{
    return [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : 20;
}

/**
 * @method isValidOffset:
 *
 * Checks whether the given offset is valid.
 * The negative offset must be lower than
 * fully expanded navbar's max y position.
 *
 * @param offset - of scrollview
 * @return YES if valid offset; otherwise, NO.
 */
- (BOOL)isValidOffset:(CGFloat)offset;
{
   CGFloat navbarMaxY = [self statusbarHeight] + navbarHeight;
   return -offset < navbarMaxY;
}

/**
 * @method validDelta:
 *
 * Calculate limit according direction of delta,
 * and the displacement to the calculated limit.
 * Return the value that has the smaller abs value,
 * between the delta & displacement.
 * This ensures navbar doesn't fall short when scrolling.
 *
 * @param delta - of scroll
 * @return disp to limit if delta crosses limit; otherwise, delta.
 */
- (CGFloat)validDelta:(CGFloat)delta
{
    CGFloat limit = [self statusbarHeight];
    if (delta > 0) limit += navbarHeight;
    
    //get displacement
    CGFloat displ = limit - CGRectGetMaxY(self.navbar.frame);
    return ( fabsf(delta) < fabsf(displ) ) ? delta : displ;
}

@end
