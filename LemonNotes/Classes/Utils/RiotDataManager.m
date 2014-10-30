
#import "RiotDataManager.h"
#import <sqlite3.h>

@interface RiotDataManager()
{
    sqlite3*  db;
}

    //DB constant inst vars
@property (nonatomic, strong) NSString* documentsDirectory;
@property (nonatomic, strong) NSString* dbFilename;
@property (nonatomic, strong) NSString* dbFilepath;

    //DB mutable result inst vars
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic, strong) NSMutableArray* results;
@property (nonatomic, strong) NSMutableArray* resultColNames;

    //LoL data management properties
@property (nonatomic, strong) NSMutableDictionary *currentVersions;

    //private setup methods
- (instancetype)initWithFilename:(NSString *)filename;
- (void)setupDB;

    //private db methods
//- (void)runQuery:(const char*)query isExectuable:(BOOL)executable;

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

/**
 * Method: init
 * Usage: init for RiotDataManager
 * --------------------------
 *
 */
- (instancetype)init
{
    return [self initWithFilename:@"LoLStaticData.sql"];
}

/**
 * Method: initWithFilename
 * Usage: init for RiotDataManager
 * --------------------------
 * Given a filename for a sql db file, sets dbFilename as given name.
 * Finds and sets path to Documents directory.
 * Calls copyDatabaseToDocuments
 *
 * @param filename - of db file
 */
- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self)
    {
        self.dbFilename = filename;
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        self.dbFilepath = [self.documentsDirectory stringByAppendingPathComponent:self.dbFilename];
        [self setupDB];
    }
    return self;
}

/**
 * Method: copyDatabaseToDocuments
 * Usages: called by initWithFilename
 * --------------------------
 * Copies sql file from main bundle to app's documents directory, if not already there.
 */
- (void)setupDB
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:self.dbFilepath] )
    {
        NSString* sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.dbFilename];
        
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:self.dbFilepath
                                                 error:&error];
        
        if (error)
            NSLog(@"%@", [error localizedDescription]);
    }
}



#pragma mark - Private DB methods
/**
 *
 *
 * --------------------------
 *
 */
- (void)runQuery:(const char*)query isExectuable:(BOOL)executable
{
    if ( sqlite3_open([self.dbFilepath UTF8String], &db) == SQLITE_OK )
    {
        sqlite3_stmt* compiledStatement;
        
        if ( sqlite3_prepare_v2(db, query, -1, &compiledStatement, NULL) == SQLITE_OK )
        {
            if (executable) //create, update, insert, etc
            {
                if ( sqlite3_step(compiledStatement) == SQLITE_DONE )
                {
                    self.affectedRows = sqlite3_changes(db);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(db);
                }
                else
                {
                    //unable to execute query
                    NSLog(@"SQLite Execute Error: %s", sqlite3_errmsg(db));
                }
            }
            else //select
            {
                
            }
        }
        else
        {
            //unable to prepare query
            NSLog(@"SQLite Prepare Error: %s", sqlite3_errmsg(db));
        }
    }
    else
    {
        //unable to open db
        NSLog(@"SQLite Open Error: %s", sqlite3_errmsg(db));
    }
}

@end

















