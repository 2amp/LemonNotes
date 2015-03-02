
#import <UIKit/UIKit.h>
#import "TAPBanner.h"

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
- (void)removeBanner;
- (void)addTopDownBannerToView:(UIView *)view type:(BannerType)type
                          text:(NSString *)text delay:(CGFloat)delay;
- (void)addBottomUpBannerToView:(UIView *)view type:(BannerType)type
                           text:(NSString *)text delay:(CGFloat)delay;
- (void)addBottomDownBannerToView:(UIView *)view type:(BannerType)type
                             text:(NSString *)text delay:(CGFloat)delay;

@end
