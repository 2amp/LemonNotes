
#import <UIKit/UIKit.h>

/**
 * Category: UIImageAdditions
 * Class: UIImage
 * --------------------------
 * Adds a method to UIImage to return a UIImage from the provided path scaled to
 * the provided dimensions.
 */

@interface UIImage (UIImageAdditions)

+ (UIImage *)imageNamed:(NSString *)name scaledToWidth:(CGFloat)width height:(CGFloat)height;

@end
