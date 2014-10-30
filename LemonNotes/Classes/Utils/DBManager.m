
#import "DBManager.h"
#import <sqlite3.h>



@interface DBManager()
{
    sqlite3*  db;
}

//DB inst vars
@property (nonatomic, strong) NSString* documentsDirectory;
@property (nonatomic, strong) NSString* currentFilename;
@property (nonatomic, strong) NSString* currentFilepath;

//private methods
- (BOOL)prepareStatement:(sqlite3_stmt *)statement WithQuery:(NSString *)query;
- (void)finalizeStatement:(sqlite3_stmt *)statement;
@end



@implementation DBManager

/**
 * Method: init
 * Usage: initializer
 * --------------------------
 */
- (instancetype)init
{
    if (self = [super init])
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
        self.currentFilename = nil;
        self.currentFilepath = nil;
        db = NULL;
    }
    return self;
}



#pragma mark - Private Methods
/**
 * Method: prepareStatement:WithQuery:
 * Usage: prepares statement with query
 * --------------------------
 * Given a pointer to a statement and a query
 * encodes query into UTF-8 and calls sqlite3_prepare_v2().
 */
- (BOOL)prepareStatement:(sqlite3_stmt *)statement WithQuery:(NSString *)query
{
    if ( sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
    {
        return YES;
    }
    
    NSLog(@"SQLite Prepare Error: %s", sqlite3_errmsg(db));
    return NO;
}

/**
 * Method: finalizeStatement
 * Usage: finalizes statement
 * --------------------------
 * Given a pointer to a statement, finalizes the statement.
 */
- (void)finalizeStatement:(sqlite3_stmt *)statement
{
    if ( sqlite3_finalize(statement) != SQLITE_OK )
        NSLog(@"SQLite Finalize Error: %s", sqlite3_errmsg(db));
}



#pragma mark - Public Methods
/**
 * Method: openDBWithFilename
 * Usage: open db file with given name
 * --------------------------
 * Given a name, opens the file at documents directory.
 * Due to sqlite3_open()'s default flags,
 * file will be created if not already there.
 * If opening fails, filename & path are set back to nil.
 * 
 * @param filename - of file to open
 * @return BOOL - for success of opening
 */
- (BOOL)openDBWithFilename:(NSString *)filename
{
    self.currentFilename = filename;
    self.currentFilepath = [self.documentsDirectory stringByAppendingPathComponent:filename];
    
    if ( sqlite3_open([self.currentFilepath UTF8String], &db) == SQLITE_OK )
    {
        NSLog(@"%@", self.currentFilepath);
        return YES;
    }
    
    NSLog(@"SQLite Open Error: %s", sqlite3_errmsg(db));
    self.currentFilename = nil;
    self.currentFilepath = nil;
    return NO;
}

/**
 * Method: closeDB
 * Usage: close currently open db
 * --------------------------
 * Closes the current db.
 * NOTE: attempting to close NULL databases will cause no trouble.
 */
- (void)closeDB
{
    sqlite3_close(db);
    self.currentFilename = nil;
    self.currentFilepath = nil;
}

/**
 * Method: columnsForTable
 * Type: fetches column names for table
 * --------------------------
 * Given a table name, returns column names.
 * 
 * Creates a query string of the form "SELECT * FROM <tablename>"
 * Passes new statement and query to prepareStatement:withQuery
 * If successfully prepared,
 * go through the number of columns and fetch their names.
 * Add the names to a results array and return a copy.
 * 
 * @param table - name of table to get column names
 * @return NSArray - of column names for given table
 */
- (NSArray *)columnsForTable:(NSString *)table
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", table];
    
    NSMutableArray *results = nil;
    sqlite3_stmt *statement;
    
    if ( sqlite3_prepare(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
    {
        results = [[NSMutableArray alloc] init];
        
        int numCols = sqlite3_column_count(statement);
        for (int i=0; i<numCols; i++)
        {
            char *nameString = (char *)sqlite3_column_name(statement, i);
            [results addObject: [NSString stringWithUTF8String:nameString]];
        }
    }
    else
    {
        NSLog(@"DB Prepare Error: %s", sqlite3_errmsg(db));
    }
    
    sqlite3_finalize(statement);
    return [results copy];
}

/**
 * Method: runResultsQuery
 * Usage: runs query to fetch data
 * --------------------------
 * Runs SQL to fetch data involving SELECT
 *
 * Passes new statement and given query to prepareStatement:withQuery
 * If successfully prepared, calls sqlite3_step() while data returned is a row.
 * For every row, goes through columns to retreive data as strings.
 *
 * @param query - to execute
 * @return NSArray - nested array of data
 */
- (NSArray *)runResultsQuery:(NSString *)query
{
    NSMutableArray *results = nil;
    NSMutableArray *dataRow = nil;
    
    sqlite3_stmt* statement;
    if ( sqlite3_prepare(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
    {
        results = [[NSMutableArray alloc] init];
        
        while ( sqlite3_step(statement) == SQLITE_ROW )
        {
            dataRow = [[NSMutableArray alloc] init]; //new row
            
            for (int i=0; i<sqlite3_column_count(statement); i++)
            {
                char *dataString = (char *)sqlite3_column_text(statement, i);
                [dataRow addObject: [NSString stringWithUTF8String:dataString]];
                
            }
            
            [results addObject:dataRow];             //add row
            dataRow = nil;                           //reset
        }
    }
    else
    {
        NSLog(@"DB Prepare Error: %s", sqlite3_errmsg(db));
    }
    
    sqlite3_finalize(statement);
    return [results copy];
}

/**
 * Method: runExecuteQuery
 * Usage: runs a query to change database
 * --------------------------
 * Runs SQL executable statements (ex. INSERT, DELETE, DROP)
 *
 * Passes the statement and query to prepareStatement:withQuery
 * If successfully prepared and sqlite3_step() returns SQLITE_DONE,
 * fills the results dictionary in the format:
 * {
 *      @"numAffectedRows":
 *      @"lastInsertRowId":
 * }
 * nil will be returned if prepare or execute fails
 *
 * @param query - to execute
 * @return NSDictionary - info about rows inserted/deleted or nil
 */
- (NSDictionary *)runExecuteQuery:(NSString *)query
{
    NSDictionary *results = nil;
    
    sqlite3_stmt *statement;
    if ( [self prepareStatement:statement WithQuery:query] )
    {
        if ( sqlite3_step(statement) == SQLITE_DONE )
        {
            results = @{
                @"numAffectedRows": [NSNumber numberWithInt: sqlite3_changes(db)],
                @"lastInsertRowId": [NSNumber numberWithLongLong: sqlite3_last_insert_rowid(db)]
            };
        }
        else //execution fail
        {
            NSLog(@"DB Execute Error: %s", sqlite3_errmsg(db));
        }
    }
    
    [self finalizeStatement:statement];
    return results;
}

@end
