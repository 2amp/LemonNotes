//
//  TAPPickerTextField.h
//  LemonNotes
//
//  Created by Christopher Fu on 12/30/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPPickerTextField : UITextField <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *selectedItem;

- (void)showPicker;
- (void)cancelChoice;
- (void)selectChoice;

@end
