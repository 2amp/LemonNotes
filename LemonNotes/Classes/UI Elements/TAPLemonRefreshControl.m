
#import "TAPLemonRefreshControl.h"


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
    BOOL pullEnded;
    BOOL canRefresh;
    CGFloat storedTopInset;
    RefreshControlState state;
}

@property (nonatomic, weak) UITableView *tableView;
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
- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init])
    {
        //Add tableView
        self.tableView = tableView;
        [self.tableView addSubview:self];
        [self.tableView sendSubviewToBack:self];
        
        //UI setup
        CGSize size = self.tableView.frame.size;
        self.frame = CGRectMake(0, 0, size.width, 0);
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
        CGFloat frameCenterX = (size.width / 2.0) - (IMAGE_SIDE / 2.0);
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frameCenterX, IMAGE_MARGIN, IMAGE_SIDE, IMAGE_SIDE)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [self.lemonParts firstObject];
        [self addSubview:self.imageView];
        
        //refresh variables
        pullEnded = NO;
        canRefresh = YES;
        storedTopInset = self.tableView.contentInset.top;
        NSLog(@"inset: %f", self.tableView.contentOffset.y);
        state = kStateIdle;
    }
    return self;
}


#pragma mark - Accessors
@synthesize isRefreshing;
- (BOOL)isRefreshing
{
    return state == kStateRefreshing;
}


#pragma mark - Scroll Control
/**
 * @method didScroll
 *
 * Called by tableView when it is scrolled.
 * Resize refresh control according to scroll.
 * If user is pulling the tableview (scrollDist is pos.)
 * and lemon refresh controls is not already spinning,
 * calculate the n'th lemon piece to add.
 * Immediate begin refreshing when lemon is completed
 */
- (void)didScroll
{
    CGFloat scrollDist = -self.tableView.contentOffset.y;
    self.frame = CGRectMake(0, -scrollDist, self.frame.size.width, scrollDist);
    
    //if not already completed lemon
    if (state == kStateIdle && canRefresh && !pullEnded)
    {
        //calcuate lemon part
        int part = scrollDist / (REFRESH_TRIGGER_HEIGHT / self.lemonParts.count);
        part = (int)MIN(part, self.lemonParts.count-1);
        self.imageView.image = self.lemonParts[part];
        NSLog(@"image? %@", self.imageView.image);
        
        //immediate refresh on completing lemon
        if (self.imageView.image == [self.lemonParts lastObject])
        {
            [self beginRefreshing];
        }
    }
}

/**
 * @method didEndDragging
 *
 * Called by tableView when user lets go of dragging.
 */
- (void)didEndDragging
{
    pullEnded = YES;
    //[self setTopInset:storedTopInset now:YES];
}


#pragma mark - Refresh Begin & End
/**
 * @method beginRefreshing
 *
 * Called when something needs loading, and UI need to indicate it.
 */
- (void)beginRefreshing
{
    canRefresh = NO;
    state = kStateRefreshing;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    CGFloat topInset = 64 + REFRESH_CONTROL_HEIGHT;
    [self setTopInset:topInset now:pullEnded];
    
    [self animate];
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
    state = kStateResetting;
    
    CGFloat topInset = 64;
    [self setTopInset:topInset now:pullEnded];
}


#pragma mark - Animation & Transitions
/**
 * @scrollTo:animated:
 *
 * Given a topInset, and flag for animation,
 * scrolls the table view to the topInset.
 * Upon finish, if the given topInset was 0,
 * resets state to Idle
 */
- (void)setTopInset:(CGFloat)topInset now:(BOOL)now
{
    storedTopInset = topInset;

    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = topInset;
    
    if (now)
    {
        [UIView animateWithDuration:0.4 animations:^(void)
        {
            self.tableView.contentInset = inset;
        }
        completion:^(BOOL finished)
        {
            if (topInset == 0)
            {
                pullEnded = NO;
                canRefresh = YES;
                state = kStateIdle;
            }
        }];
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
    //spin lemon image view
    void (^spin)() = ^()
    {
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_4);
    };
    
    //when finished
    void (^done)(BOOL finished) = ^(BOOL finished)
    {
        if (self.isRefreshing)
        {
            [self animate];
        }
        else
        {
            self.imageView.transform = CGAffineTransformMakeRotation(0);
        }
    };
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:spin completion:done];
}

@end
