
#import "NSURLSession+SynchronousTask.h"
#import "TAPDataManager.h"
#import "TAPUtil.h"
#import "Summoner.h"
#import "Match.h"


@interface TAPDataManager()
{
    dispatch_queue_t fetchQueue;
    dispatch_queue_t loadQueue;
}

//session
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, weak) NSFileManager *fileManager;

@end
#pragma mark -


@implementation TAPDataManager

#pragma mark Init Methods
/**
 * @method sharedManager
 *
 * Returns a singleton of DataManager
 * using a threadsafe GCD initialization.
 *
 * @return DataManager instance
 */
+ (instancetype)sharedManager
{
    static TAPDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

/**
 * @method init
 *
 * Initializes an NSURLSession instance for data requests.
 * Performs a champion ID data request to populate self.championIds with a 
 * dictionary mapping each champion ID to the name of the champion.
 */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        fetchQueue = dispatch_queue_create("TAPDataManager Data Fetch Queue", DISPATCH_QUEUE_CONCURRENT);
        loadQueue  = dispatch_queue_create("TAPDataManager Image Load Queue", DISPATCH_QUEUE_CONCURRENT);
        
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        self.fileManager = [NSFileManager defaultManager];
        
        [self loadData];
    }
    return self;
}


#pragma mark - Load & Save
/**
 * @method loadData
 *
 * Loads saved data from UserDefaults.
 * If not in defaults, results in nil.
 * To be called in -[init]
 */
- (void)loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.regions = @[@"br", @"eune", @"euw", @"kr", @"lan", @"las", @"na", @"oce", @"ru", @"tr"];
    self.champList = [defaults objectForKey:@"champList"];
    self.spellList = [defaults objectForKey:@"spellList"];
    self.realms = [defaults objectForKey:@"realms"];
}

/**
 * @method saveData
 *
 * Saves currently loaded data to UserDefaults.
 * To be called when app enters background (home button).
 */
- (void)saveData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.champList forKey:@"champList"];
    [defaults setObject:self.spellList forKey:@"spellList"];
    [defaults setObject:self.realms forKey:@"realms"];
}


#pragma mark - Static Data
/**
 * @method updateDataWithRegion:completionHandler
 *
 * Given a region and a callback handler,
 * fetchs list of champions and summoner spells async.
 * If there is an error, existing dictionaries are untouched.
 * Calls handler back on main queue on completion.
 */
- (void)updateDataWithRegion:(NSString *)region completionHandler:(void (^)(NSError *))handler
{
    dispatch_async(fetchQueue,
    ^{
        //realm data
        NSError *realmError = nil;
        NSHTTPURLResponse *realmResponse = nil;
        NSURL *realmURL = apiURL(kLoLStaticRealm, region, @"", @[]);
        NSData *realmData = [self.urlSession sendSynchronousDataTaskWithURL:realmURL
                                                          returningResponse:&realmResponse
                                                                      error:&realmError];
        //champion list
        NSError *champError = nil;
        NSHTTPURLResponse *champResponse = nil;
        NSURL *champListURL = apiURL(kLoLStaticChampionList, region, @"", @[@"dataById=true"]);
        NSData *champListData = [self.urlSession sendSynchronousDataTaskWithURL:champListURL
                                                             returningResponse:&champResponse
                                                                         error:&champError];
        //spells list
        NSError *spellError = nil;
        NSHTTPURLResponse *spellResponse = nil;
        NSURL *spellListURL = apiURL(kLoLStaticSpellList, region, @"", @[@"dataById=true"]);
        NSData *spellListData = [self.urlSession sendSynchronousDataTaskWithURL:spellListURL
                                                             returningResponse:&spellResponse
                                                                         error:&spellError];
       
        if (!realmError) self.realms = [NSJSONSerialization JSONObjectWithData:realmData options:kNilOptions error:nil];
        if (!champError) self.champList = [NSJSONSerialization JSONObjectWithData:champListData options:kNilOptions error:nil][@"data"];
        if (!spellError) self.spellList = [NSJSONSerialization JSONObjectWithData:spellListData options:kNilOptions error:nil][@"data"];
        
        //callback
        NSError *error = nil;
        if (champError || spellError)
            error = [NSError errorWithDomain:@"Riot LoL API Static Data Fetch Error" code:500 userInfo:nil];
       
        dispatch_async(dispatch_get_main_queue(), ^{ handler(error); });
    });
}


#pragma mark - Image Data
/**
 * @method setItemIconWithKey:toView:
 *
 * Given an item key and an UIImagView,
 * gets the icon in real time and sets it as ImageView's image.
 * 
 * If icon exists at the spcified path, just create image from data.
 * Otherwise, download from ddragon assets and create data from url.
 * 
 * @param key  - item key number
 * @param view - UIImageView to set item icon to
 */
- (void)setItemIconWithKey:(NSString *)key toView:(UIImageView *)view
{
    dispatch_async(loadQueue,
    ^{
        NSString *filename = [NSString stringWithFormat:@"%@.png", key];
        UIImage *img = [self fetchIfDoesNotExistUsingFolder:@"item_icon" filename:filename
                                                        url:imgURL(kLoLItemIcon, self.realms[@"v"], key)];
        dispatch_async(dispatch_get_main_queue(), ^{ view.image = img; });
    });
}

/**
 * @method setChampIconWithKey:toView:
 *
 * Given a champ key and an UIImageView,
 * gets the icon in real time and sets it as ImageView's image.
 *
 * @param key  - champ key name
 * @param view - UIImageView to set champ icon to
 */
- (void)setSpellIconWithKey:(NSString *)key toView:(UIImageView *)view
{
    dispatch_async(loadQueue,
    ^{
        NSString *filename = [NSString stringWithFormat:@"%@.png", key];
        UIImage *img = [self fetchIfDoesNotExistUsingFolder:@"spell_icon" filename:filename
                                                        url:imgURL(kLoLSpellIcon, self.realms[@"v"], key)];
        dispatch_async(dispatch_get_main_queue(), ^{ view.image = img; });
    });
}

/**
 * @method setChampIconWithKey:toView:
 *
 * Given a champ key and an UIImageView,
 * gets the icon in real time and sets it as ImageView's image.
 *
 * @param key  - champ key name
 * @param view - UIImageView to set champ icon to
 */
- (void)setChampIconWithKey:(NSString *)key toView:(UIImageView *)view
{
    dispatch_async(loadQueue,
    ^{
        NSString *filename = [NSString stringWithFormat:@"%@.png", key];
        UIImage *img = [self fetchIfOutdatedUsingFolder:@"champ_icon" filename:filename
                                                    url:imgURL(kLoLChampIcon, self.realms[@"v"], key)];
        dispatch_async(dispatch_get_main_queue(), ^{ view.image = img; });
    });
}

/**
 * @method setChampSplashWithKey:toView:
 *
 * Given a champ key and and UIImageView,
 * get the splash in real time and set it as ImageView's image.
 * Check if splash exists:
 * - no:  download
 * - yes: check last update time, and if longer than month, download.
 *
 * @param key  - champ key name
 * @param view - UIImageView to set champ splash to
 */
- (void)setChampSplashWithKey:(NSString *)key toView:(UIImageView *)view
{
    dispatch_async(loadQueue,
    ^{
        NSString *filename = [NSString stringWithFormat:@"%@_0.jpg", key];
        UIImage *img = [self fetchIfOutdatedUsingFolder:@"champ_splash" filename:filename url:imgURL(kLoLChampSplash, @"", key)];
        dispatch_async(dispatch_get_main_queue(), ^{ view.image = img; });
    });
}

/**
 * @method setChampSplashWithKey:toView:
 *
 * Given a champ key and and UIImageView,
 * get the splash in real time and set it as ImageView's image.
 * Check if splash exists:
 * - no:  download
 * - yes: check last update time, and if longer than month, download.
 *
 * @param key  - champ key name
 * @param view - UIImageView to set champ splash to
 */
- (void)setProfileIconWithKey:(NSString *)key toView:(UIImageView *)view
{
    dispatch_async(loadQueue,
    ^{
        NSString *filename = [NSString stringWithFormat:@"%@.png", key];
        UIImage *img = [self fetchIfDoesNotExistUsingFolder:@"profile_icon" filename:filename
                                                        url:imgURL(kLoLProfileIcon, self.realms[@"v"], key)];
        dispatch_async(dispatch_get_main_queue(), ^{ view.image = img; });
    });
}

/**
 * @method fetchIfDoesNotExistUsingFolder:filename:url:
 *
 * Given the parameters, returns an UIImage under the following conditions:
 * - image exists at expected path
 *      > fetch from local image data
 * - image doesn't exist at path
 *      > fetch image asset from ddragon
 *
 * @param folder   - for image of this category
 * @param filename - of image
 * @param url      - to fetch from
 * @return UIImage using given categories
 */
- (UIImage*)fetchIfDoesNotExistUsingFolder:(NSString *)folder filename:(NSString *)filename url:(NSURL *)url
{
    NSString *document  = [self applicationDocumentsDirectory].path;
    NSString *folders   = [@"resources/images/" stringByAppendingPathComponent:folder];
    NSString *directory = [document stringByAppendingPathComponent:folders];
    NSString *filepath  = [directory stringByAppendingPathComponent:filename];

    NSData *data = [NSData dataWithContentsOfFile:filepath];
    if (!data)
    {
        data = [NSData dataWithContentsOfURL:url];
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        [data writeToFile:filepath atomically:YES];
    }
    return [UIImage imageWithData:data];
}

/**
 * @method fetchIfOutdatedUsingFolder:filename:url:
 *
 * Given the parameters, returns an UIImage under the following conditions:
 * - image doesn't exists at expected path OR exists but is outdated (1+ months)
 *      > fetch image asset from ddragon
 * - image exists and is not oudated
 *      > fetch from local image data
 *
 * @param folder   - for image of this category
 * @param filename - of image
 * @param url      - to fetch from
 * @return UIImage using given categories
 */
- (UIImage*)fetchIfOutdatedUsingFolder:(NSString *)folder filename:(NSString *)filename url:(NSURL *)url
{
    NSString *document  = [self applicationDocumentsDirectory].path;
    NSString *folders   = [@"resources/images/" stringByAppendingPathComponent:folder];
    NSString *directory = [document stringByAppendingPathComponent:folders];
    NSString *filepath  = [directory stringByAppendingPathComponent:filename];
    
    BOOL needsUpdate = NO;
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    if (!data) needsUpdate = YES; //no image, fetch
    else
    {
        //get creation date
        NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:filepath error:nil];
        NSDate *creationDate = (NSDate*)[attributes objectForKey: NSFileCreationDate];
        
        //get months
        unsigned int flags = NSCalendarUnitMonth;
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:flags fromDate:creationDate toDate:[NSDate date] options:0];
        if ([comps month] >= 1)
            needsUpdate = YES;
    }
    
    //fetch if needs update
    if (needsUpdate)
    {
        data = [NSData dataWithContentsOfURL:url];
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        [data writeToFile:filepath atomically:YES];
    }
    
    return [UIImage imageWithData:data];
}


#pragma mark - Summoner Accounts
/**
 * @method summonnerDump
 *
 * Dumps all the summoners in core data into NSLog
 * @note method to be removed some time
 */
- (void)printSummoners
{
    // fetch for summoner entity with summonerId
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    
    NSLog(@"Summoners in CoreData:");
    for (Summoner *summoner in result)
        NSLog(@"%@ (region: %@)", summoner.name, summoner.region);
}

/**
 * @method deleteAllSummoners
 *
 * Deletes all summoners in core data
 */
- (void)deleteAllSummoners
{
    NSFetchRequest *summonerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Summoner"];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:summonerFetch error:&error];
    for (Summoner *summoner in result)
    {
        for (Match* match in summoner.matches)
            [self.managedObjectContext deleteObject:match];
        
        [self.managedObjectContext deleteObject:summoner];
    }
    [self saveContext];
    NSLog(@"%lul", [self.managedObjectContext executeFetchRequest:summonerFetch error:&error].count);
}

/**
 * @method getSummonerForName:Region:successHandler:failureHandler
 *
 * Given a summoner's name and region, attempts to fetch the summoner from Riot API.
 * If the statusCode is successful, the received data is assumed to be valid JSON and
 * converted to NSDictionary with with region included.
 * Otherwise a error message is created.
 * The callbacks are called accordingly back on the main thread.
 *
 * @param name           - name of summoner to search
 * @param region         - region to search summoner in
 * @param successHandler - code block to be called upon successful fetch
 * @param failureHandler - code block to be called upon failed fetch
 */
- (void)getSummonerForName:(NSString *)name region:(NSString *)region
            successHandler:(void (^)(NSDictionary *summoner))successHandler
            failureHandler:(void (^)(NSString *errorMessage))failureHandler
{
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:apiURL(kLoLSummonerByName, region, name, @[])
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) //successful
        {
            //retrieve and set region
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSMutableDictionary *summonerInfo = [NSMutableDictionary dictionaryWithDictionary:dataDict[[dataDict allKeys][0]]];
            [summonerInfo setObject:region forKey:@"region"];
          
            //callback on main thread
            dispatch_async(dispatch_get_main_queue(), ^{ successHandler([summonerInfo copy]); });
        }
        else
        {
            NSString *errorMessage = [NSString stringWithFormat:@"Error %d: %@", (int)httpResponse.statusCode,
                                      [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
            dispatch_async(dispatch_get_main_queue(), ^{ failureHandler(errorMessage); });
        }
    }];
    
    [task resume];
}


@end
