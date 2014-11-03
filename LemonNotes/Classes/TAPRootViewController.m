//
//  TAPMainViewController.m
//  LemonNotes
//
//  Created by Christopher Fu on 11/3/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import "TAPRootViewController.h"

@interface TAPRootViewController ()

@end

@implementation TAPRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"homeVC"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sideMenuVC"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
