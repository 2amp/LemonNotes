//
//  ViewController.m
//  LemonNotes
//
//  Created by Christopher Fu on 10/21/14.
//  Copyright (c) 2014 2 AM Productions. All rights reserved.
//

#import "TAPViewController.h"

@interface TAPViewController ()

@end

@implementation TAPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signIn:(id)sender
{
    [self showAlertWithTitle:@"Hello!" message:[NSString stringWithFormat:@"Welcome, %@.", self.signInField.text]];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.signInField.text = @"";
}

@end
