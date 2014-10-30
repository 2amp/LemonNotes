
#import <Foundation/Foundation.h>



/**
 * Class: RiotDataManager
 * Type: singleton manager
 * --------------------------
 *
 */
@interface RiotDataManager : NSObject

+ (RiotDataManager *)sharedManager;
- (void)runQuery:(const char*)query isExectuable:(BOOL)executable;

@end
