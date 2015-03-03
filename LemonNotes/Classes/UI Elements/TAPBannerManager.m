
#import "TAPBannerManager.h"

#define DEFAULT_HEIGHT 30.f
#define DEFAULT_DURATION 0.25f

@interface TAPBannerManager()

//private properties
@property (nonatomic, strong) TAPBanner *banner;

//banner
- (void)tapHandler:(UITapGestureRecognizer *)gesture;
- (void)addBannerToView:(UIView *)view type:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                    top:(BOOL)top down:(BOOL)down front:(BOOL)front;

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


#pragma mark - Banner Management
- (void)removeBannerWithAnimation:(BOOL)animation
{
    NSTimeInterval dur = (animation) ? DEFAULT_DURATION : 0;

    [self.banner hideWithDuration:dur delay:0
     handler:^(BOOL finished)
     {
         UITapGestureRecognizer *gesture = [self.banner gestureRecognizers][0];
         [self.banner removeGestureRecognizer:gesture];
         [self.banner removeFromSuperview];
         
         self.banner = nil;
     }];
}

/**
 * @method addTopDownBannerToView:type:text:delay
 *
 * Adds a banner of the given type and text with delay
 * to the view at the top so that it drops down.
 * @note this banner will be in front of other subview in view
 */
- (void)addTopDownBannerToView:(UIView *)view type:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
{
    [self addBannerToView:view type:type text:text delay:delay top:YES down:YES front:YES];
}

/**
 * @method addBottomUpBannerToView:type:text:delay
 *
 * Adds a banner of the given type and text with delay
 * to the view at the bottom so that it drops down.
 * @note this banner will be in behind of other subview in view
 */
- (void)addBottomUpBannerToView:(UIView *)view type:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
{
    [self addBannerToView:view type:type text:text delay:delay top:NO down:NO front:NO];
}

/**
 * @method addBottomDownBannerToView:type:text:delay
 *
 * Adds a banner of the given type and text with delay
 * to the view at the bottom so that it drops down.
 * @note this banner will be in behind of other subview in view
 */
- (void)addBottomDownBannerToView:(UIView *)view type:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
{
    [self addBannerToView:view type:type text:text delay:delay top:NO down:YES front:NO];
}


#pragma mark - Private Banner
/**
 * @method addBannerWithType:text:toView:top:down:front:
 *
 * Adds a banner with a bunch of options to the given view.
 *
 * @param view  - to display in
 * @param type  - of banner (changes color)
 * @param text  - to display
 * @param delay - before showing
 * @param top   - bool to place near top or bot
 * @param down  - bool to slide down or up
 * @param front - bool to place front or behind
 */
- (void)addBannerToView:(UIView *)view type:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                    top:(BOOL)top down:(BOOL)down front:(BOOL)front
{
    TAPBanner *banner = [TAPBanner bannerWithType:type text:text];
    
    //size calculations
    CGFloat width  = view.frame.size.width;
    CGFloat height = DEFAULT_HEIGHT;
    if (top) height += [self statusbarHeight];
    CGFloat edge  = top  ? 0 : view.frame.size.height;
    CGFloat delta = down ? height : -height;
    
    //set frames
    banner.hideFrame = (CGRect){0, edge - delta, width, height};
    banner.showFrame = (CGRect){0, edge,         width, height};
    banner.frame = banner.hideFrame;

    //add to view
    [view addSubview:banner];
    if (front) [view bringSubviewToFront:banner];
    else       [view sendSubviewToBack:banner];
    
    //gesture
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [banner addGestureRecognizer:gesture];
    
    //showing new
    void (^completionHandler)(BOOL) = ^(BOOL finished)
    {
        UITapGestureRecognizer *gesture = [self.banner gestureRecognizers][0];
        [self.banner removeGestureRecognizer:gesture];
        [self.banner removeFromSuperview];
        
        self.banner = banner;
        [self.banner show];
    };
    
    if (!self.banner)
    {
        self.banner = banner;
        [self.banner show];
    }
    else
        [self.banner hideWithHandler:completionHandler];
}

#pragma mark - Private Helpers
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
 * @method tapHandler
 *
 * Callback for tap on banner.
 * Removes gestureRecognizer from banner and hides it.
 */
- (void)tapHandler:(UITapGestureRecognizer *)gesture
{
    [self removeBannerWithAnimation:YES];
}

@end


