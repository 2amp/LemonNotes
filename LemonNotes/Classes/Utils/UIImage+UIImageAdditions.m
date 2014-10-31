
#import "UIImage+UIImageAdditions.h"

@implementation UIImage (UIImageAdditions)

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
