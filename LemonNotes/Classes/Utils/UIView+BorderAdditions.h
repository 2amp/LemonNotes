
#import <UIKit/UIKit.h>

/**
 * @category UIImageViewAdditions
 * @brief    UIImageViewAdditions
 *
 * Adds some convenience methods to control UIImageViews
 *
 * @author Bohui (Dennis) Moon
 * @version 0.1
 */
@interface UIView (BorderAdditions)

- (void)setBorderRadius:(CGFloat)radius;
- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color;

@end
