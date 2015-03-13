
#import <UIKit/UIKit.h>
#import "TAPBanner.h"

typedef NS_ENUM(int, BannerType)
{
    BannerTypeIncomplete = 0,
    BannerTypeComplete,
    BannerTypeWarning,
    BannerTypeError
};

/**
 * @class TAPBannerManager
 * @brief TAPBannerManager
 *
 * Singleton Util Manger to control the creation, showing, and hiding of banners.
 *
 * To add a banner, call one of the addBanner methods with
 * the view to add the banner to, customization params, and callbacks.
 *
 * The following will remove currently shown banner:
 * - Add another banner
 * - Call one of the removeBanner methods
 * - User taps banner or clicks cancel button
 *
 * @author Bohui Moon
 */
@interface TAPBannerManager : NSObject

//init
+ (instancetype)sharedManager;

//removing banners
- (void)removeBannerWithAnimation:(BOOL)animation;
- (void)removeBannerWithAnimation:(BOOL)animation handler:(void (^)())handler;

//no handlers
- (void)addBannerToTopOfView:(UIView *)view
                    withType:(BannerType)type
                        text:(NSString *)text
                       delay:(CGFloat)delay;
- (void)addBannerToBottomOfView:(UIView *)view
                       withType:(BannerType)type
                           text:(NSString *)text
                          delay:(CGFloat)delay;

//with handlers
- (void)addBannerToTopOfView:(UIView *)view
                    withType:(BannerType)type
                        text:(NSString *)text
                       delay:(CGFloat)delay
                  tapHandler:(void (^)())tapHandler
               cancelHandler:(void (^)())cancelHandler;
- (void)addBannerToBottomOfView:(UIView *)view
                       withType:(BannerType)type
                           text:(NSString *)text
                          delay:(CGFloat)delay
                     tapHandler:(void (^)())tapHandler
                  cancelHandler:(void (^)())cancelHandler;

@end
