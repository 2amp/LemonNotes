
#import "TAPScrollNavbar.h"

@interface TAPScrollNavbar()
{
    BOOL dragging;
    CGFloat height;
    CGFloat savedOffset;
    CGFloat previousOffset;
}

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, weak  ) UIScrollView *scrollView;
@property (nonatomic, strong) UIPanGestureRecognizer *gesture;

@end
#pragma mark -

@implementation TAPScrollNavbar
#pragma mark Init
/**
 * @method initWithNavbar
 *
 * Creates a ScrollNavbar given another navbar.
 * Copies some basic properties over.
 *
 * @param navbar - to use as template
 */
- (instancetype)initWithNavbar:(UINavigationBar *)navbar
{
    if(self = [self initWithFrame:navbar.frame])
    {
        self.barStyle = navbar.barStyle;
        self.tintColor = navbar.tintColor;
        self.barTintColor = navbar.barTintColor;
    }
    return self;
}

/**
 * @method initWithView
 *
 * Creates a ScrollingNavbar with the given frame
 * @param frame - frame of navbar
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        dragging = NO;
        height = self.frame.size.height;
        
        //overlay
        self.overlay = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.overlay];
        [self bringSubviewToFront:self.overlay];
        
        //gesture
//        self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollHandler)];
//        self.gesture.maximumNumberOfTouches = 1;
//        self.gesture.delegate = self;
    }
    return self;
}


#pragma mark - Setup
/**
 * @method revertToSaved
 *
 * Reverts navbar's frame to saved offset,
 * and calls adjust opacity to modify accordingly.
 */
- (void)revertToSaved
{
    CGRect frame = self.frame;
    frame.origin.y = savedOffset;
    self.frame = frame;
    
    [self adjustItemOpacity];
}

/**
 * @method unfollowCurrentView
 *
 * ScrollNavbar stops reacting to scroll of currently set view
 */
- (void)unfollowCurrentView
{
    if (self.scrollView)
    {
        [self.scrollView removeGestureRecognizer:self.gesture];
        self.scrollView = nil;
    }
}

/**
 * @method followView
 *
 * ScrollingNavbar reacts to the scroll of given view
 * by attaching PanGestureRecognizer to the view.
 *
 * @param scrollView - to follow and adjust to
 */
- (void)followView:(UIScrollView *)scrollView
{
    [self unfollowCurrentView];
    
    self.scrollView = scrollView;
    [self.scrollView addGestureRecognizer:self.gesture];
}


#pragma mark - Scroll Events
/**
 * @method scrollHandler
 *
 * Callback for PanGestureRecognizer for when following view is scrolled.
 * Calculates delta from last states and adjsts navbar accordingly.
 */
- (void)scrollHandler
{
    CGFloat currentOffset = self.scrollView.contentOffset.y;
    CGFloat delta = [self validDelta:(previousOffset - currentOffset)];
    
    if ([self isValidOffset:currentOffset] || [self isValidOffset:previousOffset])
    {
        [self scrollNavbarWithDelta:delta];
        [self adjustScrollView:self.scrollView toDelta:delta];
    }
    previousOffset = currentOffset;
    
    if ([self.gesture state] == UIGestureRecognizerStateEnded || [self.gesture state] == UIGestureRecognizerStateCancelled)
    {
        [self preventPartialScroll:self.scrollView];
    }
    [self adjustItemOpacity];
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
    dragging = YES;
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
    
    if ([self isValidOffset:currentOffset] || [self isValidOffset:previousOffset])
    {
        [self scrollNavbarWithDelta:delta];
        [self adjustScrollView:scrollView toDelta:delta];
    }
    [self adjustItemOpacity];
    previousOffset = currentOffset;
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
    dragging = NO;
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
    CGRect frame = self.frame;
    frame.origin.y += delta;
    self.frame = frame;
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
    UIEdgeInsets insets = scrollView.scrollIndicatorInsets;
    insets.top += delta;
    scrollView.scrollIndicatorInsets = insets;
    
    savedOffset = CGRectGetMinY(self.frame);
}

/**
 * @method adjustItemOpacity
 *
 * Adjust transparency of navbar's top navigation item
 * according to the scroll & position of navbar.
 */
- (void)adjustItemOpacity
{
    CGFloat navbarEdge = [self bottomEdge] - [self statusbarHeight];
    CGFloat alpha = navbarEdge / height;

    //overlay and tint
    [self.overlay setAlpha:1 - alpha];
    self.tintColor = [self.tintColor colorWithAlphaComponent:alpha];
    
    //top item
    UINavigationItem *topItem = self.topItem;
    topItem.titleView.alpha = alpha;
    [topItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *obj, NSUInteger idx, BOOL *stop) {
        obj.customView.alpha = alpha;
    }];
    topItem.leftBarButtonItem.customView.alpha = alpha;
    [topItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *obj, NSUInteger idx, BOOL *stop) {
        obj.customView.alpha = alpha;
    }];
    topItem.rightBarButtonItem.customView.alpha = alpha;
}

/**
 * @method preventPartialScroll:
 *
 * Prevents any partially scrolled navbars when user
 * stops scrolling/dragging at non-edge case values.
 * Operations will only trigger if navbar's bottom edge
 * is between the status bar and its bottom limit.
 * To account for scrolling errors, a 2 pt margin is given
 * when scrolling down (expanding navbar) so that
 * navbar doesn't revert back to hiding when not wanted.
 *
 * @param scrollView - to prevent partial scrolling
 */
- (void)preventPartialScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.frame;
    CGFloat bottomEdge = CGRectGetMaxY(frame);
    
    //navbar is not fully scrolled to top or bottom limit
    if ([self statusbarHeight] < bottomEdge && bottomEdge < [self bottomLimit])
    {
        CGFloat deltaToStatusBar = [self statusbarHeight] - CGRectGetMaxY(frame);
        
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
 *
 * @return CGFloat of status bar height
 */
- (CGFloat)statusbarHeight
{
    return [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : 20;
}

/**
 * @method bottomEdge
 *
 * Returns the current y-value of the navbar's bottom edge,
 * which is computed as its offset + height.
 *
 * @return MaxY or bottom edge value of navbar
 */
- (CGFloat)bottomEdge
{
    return CGRectGetMaxY(self.frame);
}

/**
 * @method bottomLimit
 *
 * Returns the max bottom edge value navbar can take on,
 * which is the statusbar + navbar's height.
 * Instead of hard coding the value 64 (portrait mode),
 * this accounts for landscape mode, too.
 *
 * @return bottom limit or furthest navbar can be pulled down
 */
- (CGFloat)bottomLimit
{
    return [self statusbarHeight] + height;
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
    return -offset < [self statusbarHeight] + height;
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
    if (delta > 0) limit += height;
    
        //get displacement
    CGFloat displ = limit - [self bottomEdge];
    return ( fabsf(delta) < fabsf(displ) ) ? delta : displ;
}

@end
