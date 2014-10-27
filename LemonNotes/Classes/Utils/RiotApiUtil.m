
#import "RiotApiUtil.h"



@interface RiotApiUtil()



@end



@implementation RiotApiUtil

//synthesize instance
//ex) @synthesize someProperty;

/**
 * Func: sharedUtil
 * Usage: get singleton of RiotApiUtil
 * --------------------------
 * Uses a thread safe method to init and return sharedUtil. 
 * REF: http://www.galloway.me.uk/tutorials/singleton-classes/
 */
+ (RiotApiUtil *)sharedUtil
{
    static RiotApiUtil *sharedUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtil = [[self alloc] init];
    });
    return sharedUtil;
}

/**
 * Method: init
 * Usage: for initializing singleton
 * --------------------------
 * Should only be called by +sharedUtil
 *
 * Calls NSObject's init to use ARC
 * if initialized correctly, defines instance variables.
 * Returns itself.
 *
 * @return instancetype - should be RiotApiUtil*
 */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //initialize any instance vars
        //someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
    }
    return self;
}

@end
