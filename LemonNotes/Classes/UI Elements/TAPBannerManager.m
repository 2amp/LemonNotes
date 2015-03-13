
#import "TAPBannerManager.h"

#define DEFAULT_HEIGHT 30.f
#define DEFAULT_DURATION 0.25f

@interface TAPBannerManager()

//private properties
@property (nonatomic, strong) TAPBanner *banner;

//banner
- (void)addBannerToView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                    top:(BOOL)top down:(BOOL)down front:(BOOL)front
             tapHandler:(void (^)())tapHandler cancelHandler:(void (^)())cancelHandler;

//callback
- (void)tapHandler;
- (void)cancelHandler;

//helper
- (CGFloat)statusbarHeight;
- (UIColor *)colorForBannerType:(BannerType)type;

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


#pragma mark - Accessors
/**
 * @method setBanner
 *
 * Setter for pointer to current banner.
 * Whenever a new banner is set, call show on it.
 */
- (void)setBanner:(TAPBanner *)banner
{
    _banner = banner;
    [_banner show];
}


#pragma mark - Banner Management
/**
 * @method removeBannerWithAnimation:
 *
 * Removes the current banner with animation if specified.
 * No callback upon completion, banner will just disappear.
 *
 * @param animation - flag to animate hiding banner
 */
- (void)removeBannerWithAnimation:(BOOL)animation
{
    [self removeBannerWithAnimation:animation handler:NULL];
}

/**
 * @method removeBannerWithAnimation:handler
 *
 * Removes the current banner with aniamtion if specified,
 * and calls the given handler once animation completes.
 *
 * @param animation - flag to animate hiding banner
 * @param handler   - block to run upon completion
 */
- (void)removeBannerWithAnimation:(BOOL)animation handler:(void (^)())handler
{
    NSTimeInterval dur = (animation) ? DEFAULT_DURATION : 0;

    [self.banner hideWithDuration:dur delay:0
     handler:^(BOOL finished)
     {
         if (handler) handler();
         [self.banner removeFromSuperview];
         self.banner = nil;
     }];
}


/**
 * @method addBannerToBottomOfView:view:withType:text:delay
 *
 * Adds a banner of the given type and text with delay
 * to the view at the bottom so that it drops down.
 * Nothing is done when banner is tapped or canceled.
 */
- (void)addBannerToTopOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
{
    [self addBannerToTopOfView:view withType:type text:text delay:delay tapHandler:NULL cancelHandler:NULL];
}

/**
 * @method addBannerToBottomOfView:view:withType:text:delay
 *
 * Adds a banner of the given type and text with dleay
 * to the view at the top so that it drops down.
 * Nothing is done when banner is tapped or canceled.
 */
- (void)addBannerToBottomOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
{
    [self addBannerToBottomOfView:view withType:type text:text delay:delay tapHandler:NULL cancelHandler:NULL];
}

/**
 * @method addTopDownBannerToView:withType:text:delay:tapHandler:cancelHandler
 *
 * Adds a banner of the given type and text with delay
 * to the view at the top so that it drops down.
 * Respective handlers are called when banner is tapped or canceled.
 * @note this banner will be in front of other subview in view
 */
- (void)addBannerToTopOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                  tapHandler:(void (^)())tapHandler cancelHandler:(void (^)())cancelHandler
{
    [self addBannerToView:view withType:type text:text delay:delay top:YES down:YES front:YES
               tapHandler:tapHandler cancelHandler:cancelHandler];
}

/**
 * @method addBottomDownBannerToView:type:text:delay
 *
 * Adds a banner of the given type and text with delay
 * to the view at the bottom so that it drops down.
 * @note this banner will be in behind of other subview in view
 */
- (void)addBannerToBottomOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                       tapHandler:(void (^)())tapHandler cancelHandler:(void (^)())cancelHandler
{
    [self addBannerToView:view withType:type text:text delay:delay top:NO down:YES front:NO
               tapHandler:tapHandler cancelHandler:cancelHandler];
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
- (void)addBannerToView:(UIView *)view withType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                    top:(BOOL)top down:(BOOL)down front:(BOOL)front
             tapHandler:(void (^)())tapHandler cancelHandler:(void (^)())cancelHandler
{
    TAPBanner *banner = [TAPBanner bannerWithText:text];
    banner.backgroundColor = [self colorForBannerType:type];
    
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
    
    //event handler
    banner.tapHandler = tapHandler;
    banner.cancelHandler = cancelHandler;
    [banner addTapEventTarget:self action:@selector(tapHandler)];
    [banner addCancelEventTarget:self action:@selector(cancelHandler)];
    
    //add to view
    [view addSubview:banner];
    if (front) [view bringSubviewToFront:banner];
    else       [view sendSubviewToBack:banner];
    
    //showing new
    [self.banner removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(),
    ^{
        self.banner = banner;
    });
}


#pragma mark - Event Callback
/**
 * @method tapHandler
 *
 * Callback for tap on banner.
 * Remove current banner and call its tapHandler().
 */
- (void)tapHandler
{
    [self removeBannerWithAnimation:YES handler:^{
        if (self.banner.tapHandler)
            self.banner.tapHandler();
    }];
}

/**
 * @method cancelHandler
 *
 * Callback for cancel button press on banner.
 * Remove current banner and call its cancelHandler().
 */
- (void)cancelHandler
{
    [self removeBannerWithAnimation:YES handler:^{
        if (self.banner.cancelHandler)
            self.banner.cancelHandler();
    }];
}

#pragma mark - Helpers
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
 * @method colorForBannerType:
 *
 * Given a banner type, returns correspoding color.
 *
 * @param type - banner type
 * @return color accordingly to banner type
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

@end


