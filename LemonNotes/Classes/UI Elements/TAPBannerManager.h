
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
 * There can only be one banner at any given moment.
 */
@interface TAPBannerManager : NSObject

//init
+ (instancetype)sharedManager;

//adding banners
- (void)removeBannerWithAnimation:(BOOL)animation;
- (void)addBannerToTopOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text
                       delay:(CGFloat)delay
                  tapHandler:(void (^)())tapHandler
               cancelHandler:(void (^)())cancelHandler;
- (void)addBannerToBottomOfView:(UIView *)view withType:(BannerType)type text:(NSString *)text
                          delay:(CGFloat)delay
                     tapHandler:(void (^)())tapHandler
                  cancelHandler:(void (^)())cancelHandler;

@end
