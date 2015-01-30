
#import <UIKit/UIKit.h>

@interface TAPPickerTextField : UITextField <UIPickerViewDelegate, UIPickerViewDataSource>

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@property (nonatomic, strong) NSNumber *selectedItem;
- (void)showPicker;
- (void)cancelChoice;
- (void)selectChoice;

@end
