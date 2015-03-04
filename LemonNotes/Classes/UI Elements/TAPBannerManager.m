
#import "TAPBannerManager.h"

#define DEFAULT_HEIGHT 30.f
#define DEFAULT_DURATION 0.25f

@interface TAPBannerManager()

//private properties
@property (nonatomic, strong) TAPBanner *banner;

//banner
- (UIColor *)colorForBannerType:(BannerType)type;
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


#pragma mark - Accessors
- (void)setBanner:(TAPBanner *)banner
{
    _banner = banner;
    [_banner show];
}


#pragma mark - Banner Management
/**
 * @method
 *
 *
 */
- (void)removeBannerWithAnimation:(BOOL)animation
{
    NSTimeInterval dur = (animation) ? DEFAULT_DURATION : 0;

    [self.banner hideWithDuration:dur delay:0
     handler:^(BOOL finished)
     {
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
    [banner addCancelEventTarget:self action:@selector(cancelHandler:)];
    [banner addTapEventTarget:self action:@selector(tapHandler:)];
    banner.cancelHandler = cancelHandler;
    banner.tapHandler = tapHandler;
    
    //add to view
    [view addSubview:banner];
    if (front) [view bringSubviewToFront:banner];
    else       [view sendSubviewToBack:banner];
    
    //showing new
    [self.banner removeFromSuperview];
    self.banner = banner;
}


#pragma mark - Event Callback
/**
 * @method tapHandler
 *
 * Callback for tap on banner.
 * Remove current banner and call its tapHandler().
 */
- (void)tapHandler:(UITapGestureRecognizer *)gesture
{
    [self.banner hideWithDuration:DEFAULT_DURATION delay:0
     handler:^(BOOL finished)
     {
         if (self.banner.tapHandler)
             self.banner.tapHandler();
         
         [self.banner removeFromSuperview];
         self.banner = nil;
     }];
}

/**
 * @method cancelHandler
 *
 * Callback for cancel button press on banner.
 * Remove current banner and call its cancelHandler().
 */
- (void)cancelHandler:(UIButton *)button
{
    [self.banner hideWithDuration:DEFAULT_DURATION delay:0
     handler:^(BOOL finished)
     {
         if (self.banner.cancelHandler)
             self.banner.cancelHandler();
     
         [self.banner removeFromSuperview];
         self.banner = nil;
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


