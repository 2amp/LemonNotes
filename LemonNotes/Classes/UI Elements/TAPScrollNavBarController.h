
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @class TAPScrollNavBarController
 * @brief TAPScrollNavBarController
 *
 * Handles all functions related to adjusting and modifying
 * NavigationBar according to scrolling of a ScrollView.
 * Since one ScrollView cannot have multiple delegates,
 * the primary delegate must pass on all the calls.
 */
@interface TAPScrollNavBarController : NSObject

- (instancetype)initWithNavBar:(UINavigationBar *)navbar;


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate;

@end