
#import "UIImage+UIImageAdditions.h"

@implementation UIImage (UIImageAdditions)

+ (UIImage *)imageNamed:(NSString *)name scaledToSize:(CGSize)newSize
{
    UIImage *image = [UIImage imageNamed:name];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
