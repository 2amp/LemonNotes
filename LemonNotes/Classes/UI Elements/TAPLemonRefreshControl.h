
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

- (instancetype)initWithTableView:(UITableView *)tableView;

@property (nonatomic, readonly) BOOL isRefreshing;
- (void)didScroll;
- (void)didEndDragging;
- (void)beginRefreshing;
- (void)endRefreshing;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;

@end