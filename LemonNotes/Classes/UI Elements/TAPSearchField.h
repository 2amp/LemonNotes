
#import <UIKit/UIKit.h>


/**
 * @class TAPSearchField
 * @brief TAPSearchField
 *
 */
@interface TAPSearchField : UITextField
            <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *selectedRegion;

@end
