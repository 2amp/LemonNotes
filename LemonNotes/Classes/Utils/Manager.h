
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 * @class Manager
 * @brief Manager
 *
 * Abstract superclass for all Manager type classes that
 * deal with CoreData and other local data support.
 * Not to be actually initiallized.
 *
 * @author Apple
 * @version 1.0
 */
@interface Manager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (void)saveContext;

@end
