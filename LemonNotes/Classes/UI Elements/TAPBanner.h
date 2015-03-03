
#import <UIKit/UIKit.h>

//banner types
#define DEFAULT_VER_MARGIN 0.f
#define DEFAULT_HOR_MARGIN 20.f
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

+ (instancetype)bannerWithType:(BannerType)type text:(NSString *)text;

//frames
@property (nonatomic) BOOL isHidden;
@property (nonatomic) CGRect hideFrame;
@property (nonatomic) CGRect showFrame;

//UI
@property (nonatomic, readonly) BannerType type;
@property (nonatomic, strong, readonly) UILabel *label;

//animations
- (void)show;
- (void)hide;
- (void)showWithHandler:(void (^)(BOOL))handler;
- (void)hideWithHandler:(void (^)(BOOL))handler;
- (void)showWithDelay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler;
- (void)hideWithDelay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler;
- (void)showWithDuration:(NSTimeInterval)dur delay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler;
- (void)hideWithDuration:(NSTimeInterval)dur delay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler;

@end
