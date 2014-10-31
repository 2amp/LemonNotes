
#import <UIKit/UIKit.h>

/**
 * @category UIImageAdditions
 * @brief    UIImageAdditions
 *
 * Adds a method to UIImage to return a UIImage from the provided path scaled to
 * the provided dimensions.
 *
 * @author Chris Fu
 * @version 0.1
 */
@interface UIImage (UIImageAdditions)

+ (UIImage *)imageNamed:(NSString *)name scaledToWidth:(CGFloat)width height:(CGFloat)height;

@end
