
#import <UIKit/UIKit.h>

/**
 * @class TAPLemonRefreshControl
 * @breif TAPLemonRefreshControl
 *
 * This class is eye candy that provides a spinning lemon 
 * as the activity indicator for a UIRefreshControl.
 * Before the actual refresh starts, as the user pulls,
 * the lemon is completeled 1/4 at a time.
 *
 * VC implementing this class needs to call - pulledTo:
 * when the user scrolls and pass this the offset.
 */
@interface TAPLemonRefreshControl : UIControl

@property (nonatomic) BOOL isRefreshing;

- (void)endRefreshing;
- (void)beginRefreshing;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;

@end
