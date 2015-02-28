
#import "TAPBannerManager.h"


@interface TAPBannerManager()

//default
@property (nonatomic) CGRect showFrame;
@property (nonatomic) CGRect hideFrame;
@property (nonatomic) CGFloat defaultHeight;
@property (nonatomic) CGFloat defaultHorMargin;
@property (nonatomic) CGFloat defaultVerMargin;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic, strong) UIFont *defaultFont;

//setting

//private properties
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) UIView *currentBanner;

//private methods
- (instancetype)init;
- (void)removeBanner;
- (void)showBannerWithDelay:(CGFloat)delay;
- (void)hideBannerWithHandler:(void (^)(BOOL))hander;

//banner
- (UIColor *)colorForBannerType:(BannerType)type;
- (void)tapHandler:(UITapGestureRecognizer *)gesture;
- (UIView *)bannerWithFrame:(CGRect)frame type:(BannerType)type text:(NSString *)text;

@end
#pragma mark -



@implementation TAPBannerManager
#pragma mark Init
/**
 * @method sharedManager
 *
 * Returns a singleton of DataManager
 * using a threadsafe GCD initialization.
 *
 * @return singleton instance of manager
 */
+ (instancetype)sharedManager
{
    static TAPBannerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 * @method init
 *
 * Initializer for sharedManager.
 * Other classes should not be able to create a new BannerManager.
 * Sets up all necessary default values.
 */
- (instancetype)init
{
    if (self = [super init])
    {
        self.defaultHeight = 30.f;
        self.defaultVerMargin = 0.f;
        self.defaultHorMargin = 20.f;
        self.animationDuration = 0.25f;
        self.defaultFont = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
    }
    return self;
}


#pragma mark - Banner Management
/**
 * @method addBannerWithType:text:toView:top:down:front:
 *
 * Adds a banner with a bunch of options to the given view.
 *
 * @param type  - of banner (changes color)
 * @param text  - to display
 * @param delay - before showing
 * @param view  - to display in
 * @param top   - bool to place near top or bot
 * @param down  - bool to slide down or up
 * @param front - bool to place front or behind
 */
- (void)addBannerWithType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                   toView:(UIView *)view
                      top:(BOOL)top
                     down:(BOOL)down
                    front:(BOOL)front
{
    CGRect frame = view.frame;
    UIView *banner = [self bannerWithFrame:frame type:type text:text];
    
    //subview & z-index
    [view addSubview:banner];
    if (front) [view bringSubviewToFront:banner];
    else       [view sendSubviewToBack:banner];
    
    //gesture
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [banner addGestureRecognizer:gesture];
    
    //showing new
    void (^handler)(BOOL) = ^(BOOL finished)
    {
        self.currentView = view;
        self.currentBanner = banner;
        
        CGFloat width  = banner.frame.size.width;
        CGFloat height = banner.frame.size.height;
        if (top) height += [self statusbarHeight];
        
        CGFloat edge  = top  ? 0 : view.frame.size.height;
        CGFloat delta = down ? height : -height;
        self.hideFrame = (CGRect){0, edge - delta, width, height};
        self.showFrame = (CGRect){0, edge,         width, height};
        
        banner.frame = self.hideFrame;
        [self showBannerWithDelay:delay];
    };
    
    //hiding old
    if (self.currentView && self.currentBanner)
        [self hideBannerWithHandler:handler];
    else
        handler(YES);
}

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
 * @method showBanner
 *
 *
 */
- (void)showBannerWithDelay:(CGFloat)delay
{
    [UIView animateWithDuration:self.animationDuration delay:delay options:UIViewAnimationOptionCurveLinear
    animations:^
    {
        self.currentBanner.frame = self.showFrame;
    }
    completion:^(BOOL finished){}];
}

/**
 * @method hideBanner
 *
 *
 */
- (void)removeBanner
{
    [UIView animateWithDuration:self.animationDuration
    animations:^
    {
       self.currentBanner.frame = self.hideFrame;
    }
    completion:^(BOOL finished){}];
}

- (void)hideBannerWithHandler:(void (^)(BOOL))hander
{
    [UIView animateWithDuration:self.animationDuration
    animations:^
    {
        self.currentBanner.frame = self.hideFrame;
    }
    completion:hander];
}

#pragma mark - Banner
/**
 * @method colorForBannerType:
 *
 * Given a banner type, returns correspoding color.
 */
- (UIColor *)colorForBannerType:(BannerType)type
{
    switch (type)
    {
        case BannerTypeIncomplete: return [UIColor blackColor];
        case BannerTypeComplete:   return [UIColor greenColor];
        case BannerTypeWarning:    return [UIColor orangeColor];
        case BannerTypeError:      return [UIColor redColor];
    }
    return [UIColor blackColor];
}

/**
 * @method tapHandler
 *
 * Callback for tap on banner.
 * Removes gestureRecognizer from banner and hides it.
 */
- (void)tapHandler:(UITapGestureRecognizer *)gesture
{
    [self.currentBanner removeGestureRecognizer:gesture];
    [self removeBanner];
}

/**
 * @method bannerWithType:text:
 *
 * Creates a banner with the specified type and text.
 *
 * @param type - BannerType (color)
 * @param text - message to display
 */
- (UIView *)bannerWithFrame:(CGRect)frame type:(BannerType)type text:(NSString *)text
{
    //banner
    CGRect bannerFrame = frame;
    bannerFrame.size.height = self.defaultHeight;
    
    UIView *banner = [[UIView alloc] initWithFrame:bannerFrame];
    banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    banner.backgroundColor = [self colorForBannerType:type];
    
    
    //message
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(banner.bounds, self.defaultHorMargin, self.defaultVerMargin)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = self.defaultFont;
    label.text = text;
    
    [banner addSubview:label];

    return banner;
}

@end


