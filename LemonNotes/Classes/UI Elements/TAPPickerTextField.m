
#import "TAPPickerTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "TAPDataManager.h"



@interface TAPPickerTextField()

//setup
- (void)setupPicker;

//picker
@property (nonatomic) NSInteger tempRow;
@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, strong) UITextField *pickerWrapper;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *pickerToolbar;

@end



@implementation TAPPickerTextField

/**
 * @method initWithCoder:
 *
 * Called by storyboard
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupPicker];
    }
    return self;
}

/**
 * @method initWithFrame:
 *
 * Called when manually initiallizing with frame
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupPicker];
    }
    return self;
}

/**
 * @method setupPicker
 *
 * Sets up picker
 */
- (void)setupPicker
{
    // FIXME: Currently only allows 15 to 60 in increments of 15 because of how
    // [TAPSummonerManager loadFromServer] works.
    self.choices = @[@15, @30, @45, @60];
    self.selectedItem = @30;
    if (!self.selectedItem)
    {
        self.selectedItem = @30;
    }
    self.tempRow = [self.choices indexOfObject:self.selectedItem];

    //picker
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.pickerView selectRow:self.tempRow inComponent:0 animated:NO];

    //toolbar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectChoice)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelChoice)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.pickerToolbar.items = @[cancelButton, flexibleSpace, doneButton];

    //set picker to wrapper
    self.pickerWrapper = [[UITextField alloc] init];
    self.pickerWrapper.inputView = self.pickerView;
    self.pickerWrapper.inputAccessoryView = self.pickerToolbar;
    [self addSubview:self.pickerWrapper];
    self.text = [NSString stringWithFormat:@"%@", @30];
}



#pragma mark - Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.choices count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tempRow = row;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", self.choices[row]];
}



#pragma mark - Events
/**
 * @method showPicker
 *
 * Shows picker by setting input & accessory views to picker & toolbar. Toolbar 
 * shows either Done or Search based on whether field has text. If keyboard is 
 * already up, setting inputView will not change UI. Therefore has to resign 
 * first responder first to ensure picker.
 */
- (void)showPicker
{
    NSLog(@"TAPPickerTextField %p showPicker", self);
    [self resignFirstResponder];
    [self.pickerWrapper becomeFirstResponder];
    // Selected color is some shade of gray for now
    self.backgroundColor = [UIColor colorWithRed:(220.0 / 255) green:(220.0 / 255) blue:(220.0 / 255) alpha:1.0];
}

/**
 * @method cancelChoice
 *
 * Called when user taps Cancel. Dismisses picker and resets background color.
 */
- (void)cancelChoice
{
    if ([self.pickerWrapper isFirstResponder])
    {
        self.tempRow = [self.choices indexOfObject:self.selectedItem];
        [self.pickerView selectRow:self.tempRow inComponent:0 animated:NO];
        [self.pickerWrapper resignFirstResponder];
    }
    [self resignFirstResponder];
    // Reset color
    self.backgroundColor = [UIColor clearColor];
}

/**
 * @method selectChoice
 *
 * Called when user taps Done. Dismisses picker and sets the text of the text 
 * field to the selected choice.
 */
- (void)selectChoice
{
    self.selectedItem = self.choices[self.tempRow];
    [self.pickerView selectRow:self.tempRow inComponent:0 animated:NO];

    [self.pickerWrapper resignFirstResponder];
    // Reset color and set text to selected choice
    self.backgroundColor = [UIColor clearColor];
    self.text = [NSString stringWithFormat:@"%@", self.selectedItem];
}

@end
