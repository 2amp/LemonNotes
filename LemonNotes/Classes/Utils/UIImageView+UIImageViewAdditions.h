
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
@interface UIImageView (UIImageViewAdditions)

- (void)setBorderRadius:(CGFloat)radius;
- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color;

@end
