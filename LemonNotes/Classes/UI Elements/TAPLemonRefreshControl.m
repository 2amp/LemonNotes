
#import "TAPLemonRefreshControl.h"
#import <tgmath.h>


#define IMAGE_SIDE 40.0f
#define IMAGE_MARGIN 10.0f
#define TRANSITION_DURATION 0.5f
#define REFRESH_TRIGGER_HEIGHT 100.0f
#define REFRESH_CONTROL_HEIGHT 50 + (IMAGE_MARGIN * 2) - 8

typedef enum {
    kStateIdle = 0,
    kStateRefreshing = 1,
    kStateResetting = 2
} RefreshControlState;


@interface TAPLemonRefreshControl()
{
    CGFloat startingInset;
    CGFloat diff;
    
    RefreshControlState state;
    CGFloat storedInset;
    BOOL touchEnded;
}

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *lemonParts;
@property (nonatomic, strong) UIImageView *imageView;

@end
#pragma mark -


@implementation TAPLemonRefreshControl
#pragma mark Init
/**
 * @method init
 *
 * Setups up custom UIRefreshControl with a lemon.
 * A new layer of UIView is added and the old indicator
 * is made clear so that it cannot be seen.
 * @note currently frame of imageview is setup manually
 *       should be changed soon for good coding practice.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super init])
    {
        //Add tableView
        self.scrollView = scrollView;
        [self.scrollView addSubview:self];
        [self.scrollView sendSubviewToBack:self];
        
        //UI setup
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        //setup images
        self.lemonParts = @[
            [UIImage imageNamed:@"Lemon Indicator 0.png"],
            [UIImage imageNamed:@"Lemon Indicator 1.png"],
            [UIImage imageNamed:@"Lemon Indicator 2.png"],
            [UIImage imageNamed:@"Lemon Indicator 3.png"],
            [UIImage imageNamed:@"Lemon Indicator 4.png"],
            [UIImage imageNamed:@"Lemon Indicator 5.png"],
            [UIImage imageNamed:@"Lemon Indicator 6.png"],
            [UIImage imageNamed:@"Lemon Indicator 7.png"],
            [UIImage imageNamed:@"Lemon Indicator 8.png"]
        ];
        
        //setup imageview
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [self.lemonParts firstObject];
        [self addSubview:self.imageView];
        
        state = kStateIdle;
    }
    return self;
}


#pragma mark - Accessors
/**
 * @method isRefreshing
 *
 * Getter to check whether current refreshing or not.
 * @return YES if state is refreshing; otherwise, NO.
 */
- (BOOL)isRefreshing
{
    return state == kStateRefreshing;
}

#pragma mark - Scroll Control
/**
 * @method scrollViewWillBeginDragging:
 *
 * Called when user has touched the screen is about to drag.
 * Store the starting inset for later, and adjust the size/pos
 * of this frame and the lemon image view accordingly.
 *
 * @param scrollView scrollView that will begin dragging
 */
- (void)scrollViewWillBegingDragging:(UIScrollView *)scrollView
{
    touchEnded = NO;
    startingInset = scrollView.contentInset.top;
    storedInset = startingInset;
    
    //adjust frame according to drag
    CGFloat frameWidth = CGRectGetWidth(scrollView.frame);
    self.frame = CGRectMake(0, 0, frameWidth, 0);
    
    //adjust lemon according to drag
    CGFloat centerX = frameWidth/2 - IMAGE_SIDE/2;
    self.imageView.frame = CGRectMake(centerX, IMAGE_MARGIN, IMAGE_SIDE, IMAGE_SIDE);
}

/**
 * @method scrollViewDidScroll:
 *
 * Called when user scrolls the screen by dragging.
 * The difference between the starting inset and current offset is measured.
 * Adjustments and animations are only made when diff > 0,
 * meaning that user is purposely scrolling up to refresh.
 * 
 * If not already refreshing, change the lemon icon according to base value.
 * When idle and lemon completes, immediately begin refreshing.
 *
 * When resetting after updating and diff is reverted back to 0,
 * change state to idle for next update and assure image is back to upright.
 *
 * @param scrollView that is scrolling
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffset = -scrollView.contentOffset.y;
    diff = currentOffset - startingInset;
    
    if (diff > 0)
    {
        CGRect frame = self.frame;
        frame.size.height = diff;
        frame.origin.y = -diff;
        self.frame = frame;
        
        if (state != kStateRefreshing)
        {
            CGFloat base = (state == kStateIdle) ? REFRESH_TRIGGER_HEIGHT : REFRESH_CONTROL_HEIGHT;
            int part = [self getLemonPartWith:diff basedOff:base];
            self.imageView.image = self.lemonParts[part];
            
            if (state == kStateIdle && part == self.lemonParts.count-1)
                [self beginRefreshing];
        }
    }
    
    if (state == kStateResetting && diff == 0)
        state = kStateIdle;
}

/**
 * @method scrollViewDidEndDragging:
 *
 * Called when user lifts finger from the screen.
 * Only if diff > 0, adjust the scrollview inset
 * to the stored inset (set by beging/end refreshing).
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    touchEnded = YES;
    if (diff > 0)
        [self adjustScrollViewInset];
}


#pragma mark - Refresh Control
/**
 * @method begingRefreshing
 *
 * Called when lemon is completed as user drags far enough.
 * Switch the state to refreshing, and start spinning.
 * Setting the EventValueChanged flag will trigger any
 * methods set by the class using this refresh control.
 *
 * Stored inset is set as starting inset + control height,
 * preventing refresh control from disappearing when touch is released.
 *
 * @note Only executed when state is idle to prevent multiple firing of events.
 */
- (void)beginRefreshing
{
    if (state == kStateIdle)
    {
        [self startSpin];
    
        state = kStateRefreshing;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        storedInset = startingInset + REFRESH_CONTROL_HEIGHT;
    }
}

/**
 * @method endRefreshing
 *
 * Called when updating is over and refresh control should hide.
 * Switch the state to resetting (becomes idle when fully hidden)
 * and revert inset back to starting inset by storing it.
 * If touch has already ended, revert to old inset immediately.
 *
 * @note Only executed when state is refreshing to prevent unwanted endings
 */
- (void)endRefreshing
{
    if (state == kStateRefreshing)
    {
        [self stopSpin];
        state = kStateResetting;
        
        storedInset = startingInset;
        if (touchEnded)
            [self adjustScrollViewInset];
    }
}


#pragma mark - Animations
/**
 * @method spin
 *
 * Recursively spins the lemon until refreshing is over.
 * using UIView animations and CGAffineTransform rotations.
 */
- (void)startSpin
{
    [UIView animateWithDuration:0.5 delay:0.0
     options:(UIViewAnimationCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction)
     animations:^()
     {
         self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_4);
     }
     completion:^(BOOL finished)
     {
         
     }];
}

- (void)stopSpin
{
    [UIView animateWithDuration:0.5 delay:0.0
     options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState)
     animations:^
     {
         self.imageView.transform = CGAffineTransformMakeRotation(0);
     }
     completion:^(BOOL finished)
     {
         
     }];
}


#pragma mark - Helper
/**
 * @method getLemonPartWith:basedOff:
 *
 * Given an offset and base line value,
 * calculates the lemon part to show accordingly with a floor func.
 * This allows the lemon to complete exactly when offset hits base.
 *
 * @param offset - current variable value
 * @param base   - value to calculate from
 * @return lemon part to show
 */
- (int)getLemonPartWith:(CGFloat)offset basedOff:(CGFloat)base
{
    CGFloat interval = base/(self.lemonParts.count-1);
    int part = (int)floor(offset / interval);
    return (int)MIN(part, self.lemonParts.count-1);
}

/**
 * @method adjustScrollViewInset
 *
 * Changes the inset of the scrollView to the stored value.
 * This makes the scrollView smoothly scroll to the new value,
 * because changing the inset changes the offset of the view.
 */
- (void)adjustScrollViewInset
{
    [UIView animateWithDuration:0.4
    animations:^()
    {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.top = storedInset;
        self.scrollView.contentInset  = insets;
    }];
}

@end
