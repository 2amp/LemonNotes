
#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>

/**
 * TAPRootViewController is the root vc of the entire app. It is a subclass of 
 * RESideMenu to take advantage of its side menu features. The root vc has a 
 * pointer to a content vc, which controls the current content view, and the 
 * left menu vc, which controls the side bar menu. The root vc initializes both
 * of these vcs in awakeFromNib.
 */
@interface TAPRootViewController : RESideMenu

@property (nonatomic) NSArray *recentGames;

@end
