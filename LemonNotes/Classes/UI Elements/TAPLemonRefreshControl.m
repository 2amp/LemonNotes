
#import "TAPLemonRefreshControl.h"

@interface TAPLemonRefreshControl()

@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) NSArray *lemonParts;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TAPLemonRefreshControl

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
        
        //
        self.isAnimating = NO;
        [self setClipsToBounds:YES];
        [self addSubview:self.customView];
        [self.customView setClipsToBounds:YES];
        [self.customView addSubview:self.imageView];
    }
    return self;
}

- (void)pulledTo:(CGFloat)y
{
    //set custom view size
    self.customView.frame = CGRectMake(0,0, self.bounds.size.width, -1 * y);

    //pull positions
    CGFloat pullDist = MAX(0.0, -self.frame.origin.y);
    CGFloat pullRatio = MIN( MAX(pullDist, 0.0), 100.0) / 100.0;
    
    //set image accordingly
    if (!self.isRefreshing && !self.isAnimating)
    {
        if (pullRatio < 0.25)
            self.imageView.image = self.lemonParts[0];
        else if (pullRatio < 0.50)
            self.imageView.image = self.lemonParts[1];
        else if (pullRatio < 0.75)
            self.imageView.image = self.lemonParts[2];
        else if (pullRatio < 1.00)
            self.imageView.image = self.lemonParts[3];
        else if (pullRatio >= 1.00)
            self.imageView.image = self.lemonParts[4];
    }
    
    if (self.isRefreshing && !self.isAnimating)
    {
        self.imageView.image = self.lemonParts[4];
        [self animate];
    }
}

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
            [self animate];
        else
            self.isAnimating = NO;
    };
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:spin completion:done];
}

@end
