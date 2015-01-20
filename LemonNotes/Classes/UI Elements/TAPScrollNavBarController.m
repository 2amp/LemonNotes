
#import "TAPScrollNavBarController.h"
#import <objc/runtime.h>



@interface TAPScrollNavBarController()
{
    CGFloat navbarHeight;
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
 * Store a weak reference to the given navbar,
 * and its height for convenient access later on.
 *
 * @param navbar - to controll scrolling
 */
- (instancetype)initWithNavBar:(UINavigationBar *)navbar
{
    if (self = [super init])
    {
        self.navbar = navbar;
        navbarHeight = navbar.frame.size.height;
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
        [self adjustItemOpacity];
    }
}

/**
 * @method scrollViewDidScrollToTop:
 *
 * Called when scrollView reaches the top after tapping on status bar.
 * Sets the offset to match the modified inset (doesn't happen automatically).
 *
 * @param scrollView - scrolled to the top
 */
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    CGFloat topInset = scrollView.contentInset.top;
    [scrollView setContentOffset:(CGPoint){0, -topInset} animated:NO];
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
 * @method adjustItemOpacity
 *
 * Adjust transparency of navbar's top navigation item
 * according to the scroll & position of navbar.
 */
- (void)adjustItemOpacity
{
    CGFloat navbarEdge = CGRectGetMaxY(self.navbar.frame) - [self statusbarHeight];
    CGFloat alpha = navbarEdge / navbarHeight;
    UINavigationItem *topItem = self.navbar.topItem;
    
    //set transparency
    topItem.titleView.alpha = navbarEdge / navbarHeight;
    for (UIView *view in topItem.leftBarButtonItems)
        view.alpha = alpha;
    for (UIView *view in topItem.rightBarButtonItems)
        view.alpha = alpha;
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
    CGFloat bottomEdge = CGRectGetMaxY(frame);
    
    //navbar is not fully scrolled to top or bottom limit
    if ([self statusbarHeight] < bottomEdge && bottomEdge < [self navbarBottomLimit])
    {
        CGFloat dest = [self statusbarHeight];
        
        //is within top error magin, switch destination to top
        if ([self navbarBottomLimit] - SCROLL_ERROR_MARGIN <= bottomEdge)
            dest += navbarHeight;
        
        CGFloat deltaToStatusBar = dest - CGRectGetMaxY(frame);
        
        [UIView animateWithDuration:0.1 animations:
         ^{
             CGFloat newOffest = -scrollView.contentOffset.y + deltaToStatusBar;
             
             [self scrollNavbarWithDelta:deltaToStatusBar];
             [self adjustScrollView:scrollView toDelta:deltaToStatusBar];
             
             [scrollView setContentOffset:(CGPoint){0, -newOffest} animated:NO];
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

- (CGFloat)navbarBottomEdge
{
    return CGRectGetMaxY(self.navbar.frame);
}

- (CGFloat)navbarBottomLimit
{
    return [self statusbarHeight] + navbarHeight;
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
   return -offset < [self statusbarHeight] + navbarHeight;
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
