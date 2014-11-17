
#import "TAPLemonRefreshControl.h"



@interface TAPLemonRefreshControl()

@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) UIView *customView;
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
        //hide original
        self.tintColor = [UIColor clearColor];
        
        //custom view for refreshing
        self.customView = [[UIView alloc] init];
        self.customView.backgroundColor = [UIColor whiteColor];
        
        //lemon parts
        self.lemonParts = @[
            [UIImage imageNamed:@"Lemon Indicator 0.jpg"],
            [UIImage imageNamed:@"Lemon Indicator 1.jpg"],
            [UIImage imageNamed:@"Lemon Indicator 2.jpg"],
            [UIImage imageNamed:@"Lemon Indicator 3.jpg"],
            [UIImage imageNamed:@"Lemon Indicator 4.jpg"]
        ];
        self.imageView = [[UIImageView alloc] initWithImage:self.lemonParts[4]];
        self.imageView.frame = CGRectMake(162.5, 5, 50, 50);
        
        //other
        self.isAnimating = NO;
        [self setClipsToBounds:YES];
        [self addSubview:self.customView];
        [self.customView setClipsToBounds:YES];
        [self.customView addSubview:self.imageView];
    }
    return self;
}

/**
 * @method pulledTo:
 *
 * Given the y pulled distance,
 * resets the customView's height and calculates pullDist.
 * Lemon is completed 1/4 at a time depending on pullDist.
 * When lemon starts animating, shrinking the scrollView
 * does not reduce the size of the lemon back (cuz that's werid).
 *
 * @note currently pullDist is not 100 based, but is coded like so,
 *       therefore should be changed in the near future
 * 
 * @param y - float value of the pulled distance (should be given negative)
 */
- (void)pulledTo:(CGFloat)y
{
    //set custom view size
    self.customView.frame = CGRectMake(0,0, self.bounds.size.width, -y);

    //pull positions
    CGFloat pullDist = -y;
    
    //set image accordingly
    if (!self.isAnimating)
    {
        if (pullDist >= 100)    self.imageView.image = self.lemonParts[4];
        else if (pullDist > 75) self.imageView.image = self.lemonParts[3];
        else if (pullDist > 50) self.imageView.image = self.lemonParts[2];
        else if (pullDist > 25) self.imageView.image = self.lemonParts[1];
        else if (pullDist > 0 ) self.imageView.image = self.lemonParts[0];
    }
    
    if (self.isRefreshing && !self.isAnimating)
    {
        self.imageView.image = self.lemonParts[4];
        [self animate];
    }
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
    self.isAnimating = YES;
    
    void (^spin)() = ^()
    {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_4);
    };
    
    void (^done)(BOOL finished) = ^(BOOL finished)
    {
        if (self.isAnimating)
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
    [super endRefreshing];
    
    self.isAnimating = NO;
    self.imageView.image = self.lemonParts[0];
    self.imageView.transform = CGAffineTransformMakeRotation(0);
}

@end
