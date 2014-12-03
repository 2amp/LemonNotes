
#import "TAPLemonRefreshControl.h"



@interface TAPLemonRefreshControl()

@property (nonatomic) CGFloat triggerHeight;

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
- (instancetype)init
{
    if (self = [super init])
    {
        //UI setup
        CGSize size = [UIScreen mainScreen].bounds.size;
        self.frame = CGRectMake(0, 0, size.width, 0);
        self.backgroundColor = [UIColor clearColor];
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
        
        //setu imageview
        CGFloat imageLength = 40;
        CGFloat frameCenter = (size.width / 2.0) - (imageLength / 2.0);
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frameCenter, 10, imageLength, imageLength)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [self.lemonParts firstObject];
        [self addSubview:self.imageView];
        
        //refresh variables
        self.isRefreshing = NO;
        self.triggerHeight = 150.0f;
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
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:spin completion:done];
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
    CGFloat offsetY = -scrollView.contentOffset.y;
    if (offsetY > 0)
    {
        CGSize size = self.frame.size;
        self.frame = CGRectMake(0, -offsetY, size.width, offsetY);
        
        if (offsetY >= self.triggerHeight)
        {
            [self beginRefreshing];
        }
        else if (!self.isRefreshing)
        {
            int part = offsetY / (self.triggerHeight / self.lemonParts.count);
            part = (int)MIN(part, self.lemonParts.count-1);
            self.imageView.image = self.lemonParts[part];
        }
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
