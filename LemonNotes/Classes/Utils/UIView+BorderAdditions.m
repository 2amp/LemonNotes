
#import "UIView+BorderAdditions.h"


@implementation UIView (BorderAdditions)

/**
 * @method setBorderRadius:
 *
 * Sets the border radius to the given value.
 * @param radius - to set border radius to
 */
- (void)setBorderRadius:(CGFloat)radius
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = radius;
}

/**
 * @method setBorderWidth:color:
 *
 * Sets the border width and color to the given values
 * @param width - to set width to
 * @param color - to set color to
 */
- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color
{
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
}

@end
