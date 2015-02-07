
#import "UIView+BorderAdditions.h"


@implementation UIView (BorderAdditions)
#pragma mark Full Border
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


#pragma mark - One Sided Borders
/**
 * @method addSideBorderWithColor:frame
 *
 * Adds a side border with the given color and frame by
 * creating a new layer, setting its background to the color,
 * and adding it as a sublayer of the given frame.
 * @note assumes that given frame is indeed a border
 *
 * @param color - of border
 * @param frame - modified frame as a line
 */
- (void)addSideBorderWithColor:(UIColor *)color frame:(CGRect)frame
{
    CALayer *sideBorder = [CALayer layer];
    sideBorder.backgroundColor = color.CGColor;
    sideBorder.frame = frame;
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:sideBorder];
}

/**
 * @method addTopBorderWithColor:width:
 *
 * Adds a top border to this view that eats into the view's size.
 * @note if view's height is h, it will remain h, not (h + borderWidth)
 *
 * @param color - of border
 * @param width - border thickness
 */
- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)width
{
    CGSize size = self.frame.size;
    [self addSideBorderWithColor:color frame:(CGRect){0, -width, size.width, width}];
}

/**
 * @method addLeftBorderWithColor:width:
 *
 * Adds a left border to this view that eats into the view's size.
 * @note if view's width is w, it will remain w, not (w + borderWidth)
 *
 * @param color - of border
 * @param width - border thickness
 */
- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)width
{
    CGSize size = self.frame.size;
    [self addSideBorderWithColor:color frame:(CGRect){0, 0, width, size.height}];
}

/**
 * @method addRightBorderWithColor:width:
 *
 * Adds a right border to this view that eats into the view's size.
 * @note if view's width is w, it will remain w, not (w + borderWidth)
 *
 * @param color - of border
 * @param width - border thickness
 */
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)width
{
    CGSize size = self.frame.size;
    [self addSideBorderWithColor:color frame:(CGRect){size.width - width, 0, width, size.height}];
}

/**
 * @method addBottomBorderWithColor:width:
 *
 * Adds a top border to this view that eats into the view's size.
 * @note if view's height is h, it will remain h, not (h + borderWidth)
 *
 * @param color - of border
 * @param width - border thickness
 */
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)width
{
    CGSize size = self.frame.size;
    [self addSideBorderWithColor:color frame:CGRectMake(0, size.height - width, size.width, width)];
}

@end
