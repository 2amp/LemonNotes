
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


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
- (void)removeBanner;
- (void)addBannerWithType:(BannerType)type text:(NSString *)text delay:(CGFloat)delay
                   toView:(UIView *)view
                      top:(BOOL)top
                     down:(BOOL)down
                    front:(BOOL)front;

@end
