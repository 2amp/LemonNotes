
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

- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)width;
- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)width;
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)width;
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)width;

@end
