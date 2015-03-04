
#import "TAPBanner.h"


@implementation TAPBanner
#pragma mark Init
/**
 * @method bannerWithFrame:type:text
 *
 * Returns a banner with the given properties.
 * Convenience class method to shortcut [[TAPBanner alloc] init]
 */
+ (instancetype)bannerWithText:(NSString *)text
{
    return [[TAPBanner alloc] initWithText:text];
}

/**
 * @method initWithFrame:type:text
 *
 * Given a superview's frame, banner type, and message text,
 * creates a banner using some other default properties.
 * Banner's width is flexible and message label is bottom aligned.
 *
 * @param text  - message text to display
 * @instancetype TAPBanner instance
 */
- (instancetype)initWithText:(NSString *)text
{
    if (self = [super init])
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        //label
        self.label = [[UILabel alloc] init];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
        self.label.text = text;
        [self addSubview:self.label];
        
        //button
        self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.button setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
        self.button.tintColor = [UIColor whiteColor];
        [self addSubview:self.button];
        
        //tap gesture
        self.gesture = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:self.gesture];
        
        _isHidden = YES;
    }
    return self;
}


#pragma mark - Accessors
/**
 * @method setFrame:
 *
 * Called everytime banner's frame is changed.
 * Call UIView's setFrame and 
 * modify lable and button accordingly.
 *
 * @param frame - new CGRect frame to apply
 */
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    //label
    CGFloat horMargin = 20.f;
    self.label.frame = CGRectInset(self.bounds, horMargin, 0);
    
    //button
    CGFloat allMargin = 10.f;
    CGFloat sideLength = 10.f;
    self.button.frame = (CGRect){self.frame.size.width - sideLength - allMargin,
                                 self.frame.size.height - sideLength - allMargin,
                                 sideLength, sideLength};
}


#pragma mark - Callback
/**
 * @method addTapEventTarget:action
 *
 * Given a receiver and selector action,
 * adds it to banner to be called when
 * anywhere inside the banner is tapped.
 *
 * @param target - target to send action to
 * @param action - action to send to target
 */
- (void)addTapEventTarget:(id)target action:(SEL)action
{
    [self.gesture addTarget:target action:action];
}

/**
 * @method addCancelEventTarget:action:
 *
 * Given a receiver and selector action,
 * adds it to button to be called when
 * the cancel button is clicked inside banner
 *
 * @param target - target to send action to
 * @param action - action to send to target
 */
- (void)addCancelEventTarget:(id)target action:(SEL)action
{
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Show
/**
 * @method show
 *
 * Calls show sequence with default duration
 * and nothing is executed upon completion.
 */
- (void)show
{
    [self showWithHandler:nil];
}

/**
 * @method showWithHandler:
 *
 * Given a handler, calls show sequence
 * with default duration and delay
 *
 * @param handler - code block to run upon completion
 */
- (void)showWithHandler:(void (^)(BOOL))handler
{
    [self showWithDelay:0 handler:handler];
}

/**
 * @method showWithDelay:handler:
 *
 * Given a delay and handler,
 * calls show sequence with default duration.
 *
 * @param delay - delay before animation
 * @param handler - code block to run upon completion
 */
- (void)showWithDelay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler
{
    [self showWithDuration:0.25 delay:delay handler:handler];
}

/**
 * @method showWithDuration:delay:handler:
 *
 * Given a duration, delay, and handler,
 * uses UIView animations to aniamte this to showFrame.
 *
 * @param dur   - duration of animation
 * @param delay - delay before animation
 * @param handler - code block to run upon completion
 */
- (void)showWithDuration:(NSTimeInterval)dur delay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler
{
    //must be hidden
    if (!self.isHidden) return;
    
    //otherwise animate show
    [UIView animateWithDuration:dur delay:delay options:UIViewAnimationOptionCurveLinear
    animations:^
    {
        self.frame = self.showFrame;
    }
    completion:^(BOOL finished)
    {
        _isHidden = NO;
        if (handler) handler(finished);
    }];
}

#pragma mark - Hide
/**
 * @method hide
 *
 * Calls hide sequence with default duration
 * and nothing is executed upon completion.
 */
- (void)hide
{
    [self hideWithHandler:NULL];
}

/**
 * @method hideWithHandler:
 *
 * Given a handler, calls hide sequence 
 * with default duration and delay
 *
 * @param handler - code block to run upon completion
 */
- (void)hideWithHandler:(void (^)(BOOL))handler
{
    [self hideWithDelay:0 handler:handler];
}

/**
 * @method hideWithDelay:handler:
 *
 * Given a delay and handler,
 * calls hide sequence with default duration.
 *
 * @param delay - delay before animation
 * @param handler - code block to run upon completion
 */
- (void)hideWithDelay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler
{
    [self hideWithDuration:0.25 delay:delay handler:handler];
}

/**
 * @method hideWithDuration:delay:handler:
 *
 * Given a duration, delay, and handler,
 * uses UIView animations to animate this to hideFrame.
 *
 * @param dur   - duration of animation
 * @param delay - delay before animation
 * @param handler - code block to run upon completion
 */
- (void)hideWithDuration:(NSTimeInterval)dur delay:(NSTimeInterval)delay handler:(void (^)(BOOL))handler
{
    //must be shown
    if (self.isHidden) return;
    
    //otherwise animate hide
    [UIView animateWithDuration:dur delay:delay options:UIViewAnimationOptionCurveLinear
    animations:^
    {
        self.frame = self.hideFrame;
    }
    completion:^(BOOL finished)
    {
        _isHidden = YES;
        if (handler) handler(finished);
    }];
}


@end
