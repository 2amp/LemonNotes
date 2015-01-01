
#import "TAPPickerTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "TAPDataManager.h"



@interface TAPPickerTextField()

//setup
- (void)setupPicker;

//region button
- (void)pressedRegion;

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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(selectChoice)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelChoice)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.pickerToolbar.items = @[cancelButton, flexibleSpace, doneButton];

    //set picker to wrapper
    self.pickerWrapper = [[UITextField alloc] init];
    self.pickerWrapper.inputView = self.pickerView;
    self.pickerWrapper.inputAccessoryView = self.pickerToolbar;
    [self addSubview:self.pickerWrapper];
    self.text = [NSString stringWithFormat:@"%@", @30];
}



#pragma mark - Picker
/**
 * @method numberOfComponentsInPickerView
 *
 * Only 1 column of regions
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 * @method pickerView:numberRowsInComponent
 *
 * Returns number of regions defined in DataManager
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.choices count];
}

/**
 * @method pickerView:didSelectRow:inComponent
 *
 * When a certain row is selected,
 * the region is set as summoner's region and button's title is updated
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tempRow = row;
}

/**
 * @method pickerView:titleForRow:forComponent
 *
 * Sets the row's titles as regions in uppercase
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", self.choices[row]];
}



#pragma mark - Events
/**
 * @method pressedRegion
 *
 * Called when user taps region button.
 * If not already showing picker, show it.
 * Otherwise select the choice.
 */
- (void)pressedRegion
{
    //    if ( ![self isFirstResponder] )
    //        [self showPicker];
    //    else
    //    {
    //        if ( !self.inputView )   //if keyboard
    //            [self showPicker];   //show picker
    //        else                     //already picker
    //            [self selectChoice]; //select choice
    //    }

    if (![self.pickerWrapper isFirstResponder])
    {
        [self showPicker];
    }
    else
    {
        [self selectChoice];
    }
}

/**
 * @method showPicker
 *
 * Shows picker by setting input & accessory views to picker & toolbar.
 * Toolbar shows either Done or Search based on whether field has text.
 * If keyboard is already up, setting inputView will not change UI.
 * Therefore has to resign first responder first to ensure picker.
 */
- (void)showPicker
{
    NSLog(@"TAPPickerTextField %p showPicker", self);
    [self resignFirstResponder];
    [self.pickerWrapper becomeFirstResponder];
    // some shade of gray for now
    self.backgroundColor = [UIColor colorWithRed:(220.0 / 255) green:(220.0 / 255) blue:(220.0 / 255) alpha:1.0];
}

/**
 * @method cancelChoice
 *
 * Called when user taps Cancel.
 * Revert tempRow selection back to index of selectedRegion.
 * Dismiss picker.
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
    // reset color
    self.backgroundColor = [UIColor clearColor];
}

/**
 * @method selectChoice
 *
 * Called when user taps Done.
 * Finalize the choice by setting selectedRegion to region at tempRow.
 * Change title of button to the confirmed region.
 * Dismiss picker
 */
- (void)selectChoice
{
    self.selectedItem = self.choices[self.tempRow];
    [self.pickerView selectRow:self.tempRow inComponent:0 animated:NO];

    [self.pickerWrapper resignFirstResponder];
    // reset color and set text to selected choice
    self.backgroundColor = [UIColor clearColor];
    self.text = [NSString stringWithFormat:@"%@", self.selectedItem];
}

@end
