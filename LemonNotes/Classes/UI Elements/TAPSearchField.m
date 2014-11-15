
#import "TAPSearchField.h"
#import "DataManager.h"



@interface TAPSearchField()

//setup
- (void)setupButton;
- (void)setupPicker;

//region button
@property (nonatomic, strong) UIButton *regionButton;
- (void)pressedRegion;

//toolbar
@property (nonatomic, strong) UIToolbar *regionBar;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;

//picker
@property (nonatomic) NSInteger tempRow;
@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, strong) UIPickerView *regionPicker;
- (void)showPicker;
- (void)cancelChoice;
- (void)selectChoice;
- (void)searchChoice;

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

    //toolbar
    self.regionBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone   target:self action:@selector(selectChoice)];
    self.searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleDone target:self action:@selector(searchChoice)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChoice)];
    self.flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //picker
    self.regionPicker = [[UIPickerView alloc] init];
    self.regionPicker.delegate = self;
    self.regionPicker.dataSource = self;
    self.regionPicker.backgroundColor = [UIColor whiteColor];
    [self.regionPicker selectRow:[self.regions indexOfObject:self.selectedRegion] inComponent:0 animated:NO];
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
    if ( ![self isFirstResponder] )
        [self showPicker];
    else
    {
        if ( !self.inputView )   //if keyboard
            [self showPicker];   //show picker
        else                     //already picker
            [self selectChoice]; //select choice
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
    self.regionBar.items = @[self.cancelButton, self.flexibleSpace, ([self.text isEqualToString:@""] ? self.doneButton : self.searchButton)];
    
    self.inputView = self.regionPicker;
    self.inputAccessoryView = self.regionBar;
    [self resignFirstResponder];
    [self becomeFirstResponder];
}

/**
 * @method dismissPicker
 *
 * If already picker, revert back to keyboard.
 * Then resign first responder.
 */
- (void)dismissPicker
{
    if (self.inputView) //already picker
    {
        self.inputView = nil;
        self.inputAccessoryView = nil;
    }
    [self resignFirstResponder];
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
    self.tempRow = [self.regions indexOfObject:self.selectedRegion];
    [self dismissPicker];
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
    
    [self dismissPicker];
}

/**
 * @method searchChoice
 *
 * Select the currenlty selected row and send delegate to search.
 * @note delegate's implementation of textFieldShouldReturn should be a search
 */
- (void)searchChoice
{
    [self selectChoice];
    [self.delegate textFieldShouldReturn:self];
}

@end
