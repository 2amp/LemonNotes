
#import <UIKit/UIKit.h>

@interface TAPPickerTextField : UITextField <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSNumber *selectedItem;

- (void)showPicker;
- (void)cancelChoice;
- (void)selectChoice;

@end
