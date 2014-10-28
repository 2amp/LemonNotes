
#import "RiotDataManager.h"



@interface RiotDataManager()

@property (nonatomic, strong) NSMutableDictionary *currentVersions;

@end



@implementation RiotDataManager

#pragma mark - Synthesize Properties


#pragma mark - Init Methods
/**
 * Func: sharedManager
 * Usage: to call singleton of RiotDataManager
 * --------------------------
 * Uses thread safe method to create (if not already created)
 * and return singleton of RiotDataManager
 *
 * @return RiotDataManager* singleton
 */
+ (RiotDataManager *)sharedManager
{
    static RiotDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 * Method: init
 * Usage: init for RiotDataManager
 * --------------------------
 *
 */
- (id)init
{
    self = [super init];
    if (self)
    {
        //load versions from userDefaults here
    }
    return self;
}


@end