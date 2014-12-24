//
//  TAPStatsViewController.h
//  LemonNotes
//
//  Created by Christopher Fu on 12/20/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPTeammateInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *teammateManagers;
@property NSMutableArray *teammateRecentMatches;

@end
