
#import <UIKit/UIKit.h>
#import <RESideMenu/RESideMenu.h>

@interface TAPSideMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
