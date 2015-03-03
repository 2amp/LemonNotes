
#import "TAPBanner.h"

@interface TAPBanner()

@end


@implementation TAPBanner
#pragma mark Init
/**
 * @method bannerWithFrame:type:text
 *
 * Returns a banner with the given properties.
 * Convenience class method to shortcut [[TAPBanner alloc] init]
 */
+ (instancetype)bannerWithType:(BannerType)type text:(NSString *)text
{
    return [[TAPBanner alloc] initWithType:type text:text];
}

/**
 * @method initWithFrame:type:text
 *
 * Given a superview's frame, banner type, and message text,
 * creates a banner using some other default properties.
 * Banner's width is flexible and message label is bottom aligned.
 *
 * @param type  - banner type to determine color
 * @param text  - message text to display
 * @instancetype TAPBanner instance
 */
- (instancetype)initWithType:(BannerType)type text:(NSString *)text
{
    if (self = [super init])
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _type = type;
        self.backgroundColor = [self colorForBannerType:type];
        
        _label = [[UILabel alloc] init];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
        _label.text = text;
        [self addSubview:self.label];
        
        _isHidden = YES;
    }
    return self;
}


#pragma mark - Accessors
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _label.frame = CGRectInset(self.bounds, DEFAULT_HOR_MARGIN, 0);
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
        self.isHidden = NO;
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
        self.isHidden = YES;
        if (handler) handler(finished);
    }];
}


#pragma mark - Private helpers
/**
 * @method colorForBannerType:
 *
 * Given a banner type, returns correspoding color.
 *
 * @param type - banner type
 * @return color accordingly to banner type
 */
- (UIColor *)colorForBannerType:(BannerType)type
{
    switch (type)
    {
        case BannerTypeIncomplete: return [UIColor blackColor];
        case BannerTypeComplete:   return [UIColor greenColor];
        case BannerTypeWarning:    return [UIColor orangeColor];
        case BannerTypeError:      return [UIColor redColor];
    }
    return [UIColor blackColor];
}

@end
