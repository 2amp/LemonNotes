
#import <UIKit/UIKit.h>

/**
 * @class TAPLemonRefreshControl
 * @breif TAPLemonRefreshControl
 *
 * This class is eye candy that provides
 * a spinning lemon as the activity indicator
 * for a UIRefreshControl.
 */
@interface TAPLemonRefreshControl : UIRefreshControl

- (void)pulledTo:(CGFloat)y;

@end
