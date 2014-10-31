
#import "UIImage+UIImageAdditions.h"



@implementation UIImage (UIImageAdditions)

/**
 * @method imageNamed:scaledToWidth:height:
 * 
 * @brief [UIImage imageNamed:path scaledToWidth:width height:height]
 *
 * Returns a UIImage from the provided path scaled to the provided dimensions.
 *
 * @param name      NSString of the image
 * @param width     CGFloat value of width
 * @param height    CGFloat value of height
 * @return UIImage object with given name and dimension
 */
+ (UIImage *)imageNamed:(NSString *)name scaledToWidth:(CGFloat)width height:(CGFloat)height
{
    UIImage *image = [UIImage imageNamed:name];
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
