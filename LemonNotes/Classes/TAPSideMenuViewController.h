
#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>



/**
 * TAPSideMenuViewController is the view controller for the side menu. It 
 * contains a table view that currently has two cells that correspond to the
 * home and start game vcs. Tapping on either cell dismisses the side menu
 * and switches the content vc of the root vc to the selected vc.
 */
@interface TAPSideMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *contentViewControllers;

@end
