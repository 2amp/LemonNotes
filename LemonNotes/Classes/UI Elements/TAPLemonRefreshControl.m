
#import "TAPLemonRefreshControl.h"



@interface TAPLemonRefreshControl()

@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, strong) NSArray *lemonParts;
@property (nonatomic, strong) UIImageView *imageView;

@end




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
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        //lemon image
        CGFloat imageLength = 30;
        CGFloat frameCenter = (frame.size.width / 2.0)- imageLength/2.0;
        self.imageView.frame = CGRectMake(frameCenter, 5, imageLength, imageLength);
        self.lemonParts = @[
            [UIImage imageNamed:@"Lemon Indicator 0.png"],
            [UIImage imageNamed:@"Lemon Indicator 1.png"],
            [UIImage imageNamed:@"Lemon Indicator 2.png"],
            [UIImage imageNamed:@"Lemon Indicator 3.png"],
            [UIImage imageNamed:@"Lemon Indicator 4.png"],
            [UIImage imageNamed:@"Lemon Indicator 5.png"],
            [UIImage imageNamed:@"Lemon Indicator 6.png"],
            [UIImage imageNamed:@"Lemon Indicator 7.png"],
            [UIImage imageNamed:@"Lemon Indicator 8.png"],
        ];
        self.imageView = [[UIImageView alloc] initWithImage:self.lemonParts[8]];
        
        //other
        self.isRefreshing = NO;
        [self setClipsToBounds:YES];
    }
    return self;
}

/**
 * @method animate
 *
 * Recursively animates (spins) lemon while refreshing.
 * After a 0.3 animtation, if refreshing is not over,
 * - animate calls itself to for another 0.3 animation.
 */
- (void)animate
{
    self.isRefreshing = YES;
    
    void (^spin)() = ^()
    {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_4);
    };
    
    void (^done)(BOOL finished) = ^(BOOL finished)
    {
        if (self.isRefreshing)
        {
            [self animate];
        }
    };
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:spin completion:done];
}

/**
 * @method endRefreshing
 *
 * Called when VC has loaded what it needs, and wants to end refhresing.
 * Necessary components are reset:
 *      - isAnimating set to NO
 *      - image set back to blank 
 *      - tranform set back to upright
 */
- (void)endRefreshing
{
    self.isRefreshing = NO;
    self.imageView.image = self.lemonParts[0];
    self.imageView.transform = CGAffineTransformMakeRotation(0);
}

/**
 * @method beginRefreshing
 *
 * Called when something needs loading, and UI need to indicate it.
 *
 */
- (void)beginRefreshing
{
    self.isRefreshing = YES;
    [self animate];
}

/**
 * @method didScroll
 *
 *
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    if (offset < 0)
    {
        
    }
}

/**
 * @method didEndDragging:
 *
 *
 *
 * @param scrollView to which this RefreshControl is attached to
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    CGFloat triggerHeight = 50.0f;
    if (scrollView.contentOffset.y <= -triggerHeight)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
