
#import <UIKit/UIKit.h>

//banner types
typedef NS_ENUM(int, BannerType)
{
    BannerTypeIncomplete = 0,
    BannerTypeComplete,
    BannerTypeWarning,
    BannerTypeError
};

/**
 * @class TAPBanner
 * @brief TAPBanner
 *
 * Standalone class of a drop-down banner notification.
 * Contains several UI related properties,
 * in addition to its predetermined show and hide frames.
 */
@interface TAPBanner : UIView

@end
