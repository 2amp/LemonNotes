
#import <UIKit/UIKit.h>

/**
 * @class TAPScrollNavbar
 * @brief TAPScrollNavbar
 *
 *
 */
@interface TAPScrollNavbar : UINavigationBar <UIGestureRecognizerDelegate>

//init
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithNavbar:(UINavigationBar *)navbar;

//
- (void)revertToSaved;
- (void)unfollowCurrentView;
- (void)followView:(UIScrollView *)scrollView;

//scrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate;

@end
