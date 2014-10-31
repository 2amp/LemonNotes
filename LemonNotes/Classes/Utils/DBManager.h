
#import <Foundation/Foundation.h>

/**
 * Class: DBManager
 * Type: SQLite manager
 * --------------------------
 * Provides a class to easily work with SQLite Database file.
 *
 */
@interface DBManager : NSObject



- (BOOL)openDBWithFilename:(NSString *)filename;
- (void)closeDB;

- (NSArray *)     columnsForTable:(NSString *)table;
- (NSArray *)     runResultsQuery:(NSString *)query;
- (NSDictionary *)runExecuteQuery:(NSString *)query;
@end
