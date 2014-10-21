//
//  ViewController.h
//  LemonNotes
//
//  Created by Christopher Fu on 10/21/14.
//  Copyright (c) 2014 2 AM Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *signInField;
- (IBAction)signIn:(id)sender;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

