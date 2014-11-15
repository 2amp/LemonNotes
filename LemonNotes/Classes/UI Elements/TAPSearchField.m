
#import "TAPSearchField.h"
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"



@interface TAPSearchField()

//setup
- (void)setupButton;
- (void)setupPicker;

//region button
@property (nonatomic, strong) UIButton *regionButton;
- (void)pressedRegion;

//picker
@property (nonatomic) NSInteger tempRow;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) UIToolbar *regionToolBar;
@property (nonatomic, strong) UITextField *pickerWrapper;
@property (nonatomic, strong) UIPickerView *regionPicker;
- (void)showPicker;
- (void)cancelChoice;
- (void)selectChoice;

@end



@implementation TAPSearchField

/**
 * @method initWithCoder:
 *
 * Called by storyboard
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupButton];
        [self setupPicker];
    }
    return self;
}

/**
 * @method setupButton
 *
 * Sets up region button as right view
 */
- (void)setupButton
{
    self.regionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.regionButton setFrame:CGRectMake(0,0, 40, 26)];
    [self.regionButton setTitle:@"NA" forState:UIControlStateNormal];
    [self.regionButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [self.regionButton addTarget:self action:@selector(pressedRegion) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightView = self.regionButton;
    self.rightViewMode = UITextFieldViewModeAlways;
}

/**
 * @method setupPicker
 *
 * Setups up picker
 */
- (void)setupPicker
{
    //get regions & default to NA unless stored otherwises
    self.regions = [DataManager sharedManager].regions;
    self.selectedRegion = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentSummoner"][@"region"];
    if (!self.selectedRegion)
        self.selectedRegion = @"na";
    self.tempRow = [self.regions indexOfObject:self.selectedRegion];
    
    //picker
    self.regionPicker = [[UIPickerView alloc] init];
    self.regionPicker.delegate = self;
    self.regionPicker.dataSource = self;
    self.regionPicker.backgroundColor = [UIColor whiteColor];
    [self.regionPicker selectRow:self.tempRow inComponent:0 animated:NO];
    
    //toolbar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(selectChoice)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelChoice)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.regionToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.regionToolBar.items = @[cancelButton, flexibleSpace, doneButton];
    
    //set picker to wrapper
    self.pickerWrapper = [[UITextField alloc] init];
    self.pickerWrapper.inputView = self.regionPicker;
    self.pickerWrapper.inputAccessoryView = self.regionToolBar;
    [self addSubview:self.pickerWrapper];
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
    return [self.regions count];
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
    return [self.regions[row] uppercaseString];
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

    if ( ![self.pickerWrapper isFirstResponder] )
        [self showPicker];
    else
        [self selectChoice];
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
    [self resignFirstResponder];
    [self.pickerWrapper becomeFirstResponder];
}

/**
 * @method cancelChoice
 *
 * Called when user taps Cancel.
 * Revert tempRow selection back to index of selecteRegion.
 * Dismiss picker.
 */
- (void)cancelChoice
{
    if ([self.pickerWrapper isFirstResponder])
    {
        self.tempRow = [self.regions indexOfObject:self.selectedRegion];
        [self.regionPicker selectRow:self.tempRow inComponent:0 animated:NO];
        [self.pickerWrapper resignFirstResponder];
    }
    [self resignFirstResponder];
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
    self.selectedRegion = self.regions[self.tempRow];
    [self.regionPicker selectRow:self.tempRow inComponent:0 animated:NO];
    [self.regionButton setTitle:[self.selectedRegion uppercaseString] forState:UIControlStateNormal];
    
    [self.pickerWrapper resignFirstResponder];
}

@end
