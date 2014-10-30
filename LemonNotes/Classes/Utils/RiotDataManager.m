
#import "RiotDataManager.h"
#import <sqlite3.h>

@interface RiotDataManager()



@end


#pragma mark -
@implementation RiotDataManager

#pragma mark Synthesize Properties


#pragma mark - Setup Methods
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






@end

















