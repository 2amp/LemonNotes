
#import "TAPLemonRefreshControl.h"
#import <tgmath.h>


#define IMAGE_SIDE 40.0f
#define IMAGE_MARGIN 10.0f
#define TRANSITION_DURATION 0.5f
#define REFRESH_TRIGGER_HEIGHT 150.0f
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


#pragma mark - Scroll Control
- (void)scrollViewWillBegingDragging:(UIScrollView *)scrollView
{
    touchEnded = NO;
    startingInset = scrollView.contentInset.top;
    
    //adjust frame according to drag
    CGFloat frameWidth = CGRectGetWidth(scrollView.frame);
    self.frame = CGRectMake(0, 0, frameWidth, 0);
    
    //adjust lemon according to drag
    CGFloat centerX = frameWidth/2 - IMAGE_SIDE/2;
    self.imageView.frame = CGRectMake(centerX, IMAGE_MARGIN, IMAGE_SIDE, IMAGE_SIDE);
}

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
    {
        state = kStateIdle;
        self.imageView.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    touchEnded = YES;
    if (diff > 0)
        [self adjustScrollViewInset];
}


#pragma mark - Refresh Control
- (void)beginRefreshing
{
    if (state == kStateIdle)
    {
        state = kStateRefreshing;
    
        [self spin];
        storedInset = startingInset + REFRESH_CONTROL_HEIGHT;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)endRefreshing
{
    if (state == kStateRefreshing)
    {
        state = kStateResetting;
        
        storedInset = startingInset;
        if (touchEnded)
            [self adjustScrollViewInset];
    }
}


#pragma mark - Animations
- (void)spin
{
    [UIView animateWithDuration:0.4 delay:0.0 options:kNilOptions
    animations:^()
    {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
    }
    completion:^(BOOL finished)
    {
        if (state == kStateRefreshing)
            [self spin];
    }];
}


#pragma mark - Helper
- (int)getLemonPartWith:(CGFloat)offset basedOff:(CGFloat)base
{
    CGFloat interval = base/(self.lemonParts.count-1);
    int part = (int)floor(offset / interval);
    return (int)MIN(part, self.lemonParts.count-1);
}

- (void)adjustScrollViewInset
{
    [UIView animateWithDuration:0.4
    animations:^()
    {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.top = storedInset;
        self.scrollView.contentInset = insets;
    }];
}

@end
