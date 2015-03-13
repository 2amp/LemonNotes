
#import <UIKit/UIKit.h>

/**
 * @class TAPBanner
 * @brief TAPBanner
 *
 * Standalone class of a drop-down banner notification.
 * Contains several UI related properties,
 * in addition to its predetermined show and hide frames.
 *
 * @author Bohui Moon
 */
@interface TAPBanner : UIView

+ (instancetype)bannerWithText:(NSString *)text;

//properties
@property (nonatomic) CGRect hideFrame;
@property (nonatomic) CGRect showFrame;
@property (nonatomic, readonly) BOOL isHidden;

//UI
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

//callback
@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (copy) void (^tapHandler)();
@property (copy) void (^cancelHandler)();
- (void)addTapEventTarget:(id)target action:(SEL)action;
- (void)addCancelEventTarget:(id)target action:(SEL)action;

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
