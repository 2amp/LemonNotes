
#import "TAPAppDelegate.h"
#import "DataManager.h"
#import "TAPHomeViewController.h"
#import "TAPSignInViewController.h"



@interface TAPAppDelegate ()

@end

@implementation TAPAppDelegate


/**
 * @method application:didFinishLaunchingWithOptions
 * 
 * Always deletes any existing summonerId value from user defaults to 
 * temporarily default to the sign in VC in order to fetch match history data 
 * until we get data caching in Core Data working.
 * Registers any template for NSUserDefaults.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //for now clear defaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    //register values for defaults that have never been set before
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"realm":@{
            @"v"          : @"4.18.1",
            @"dd"         : @"4.17.1",
            @"cdn"        : @"http://ddragon.leagueoflegends.com/cdn",
            @"champion"   : @"4.18.1",
            @"profileicon": @"4.18.1",
            @"item"       : @"4.18.1",
            @"mastery"    : @"4.17.1",
            @"language"   : @"4.17.1",
            @"summoner"   : @"4.18.1",
            @"rune"       : @"4.17.1"
        }
    }];
    
    //data updates
    [[DataManager sharedManager] updateChampionIds];
    [[DataManager sharedManager] updateSummonerSpells];

    // FIXME: Currently deleting all summoners at app start so I don't have to
    // keep on nuking the db file. Remove when matches are no longer duplicated.
//    [[DataManager sharedManager] deleteAllSummoners];

    NSString *summonerId = [[NSUserDefaults standardUserDefaults] objectForKey:@"summonerId"];
    
    //programmatically setup initialVC
    NSString *initialVCID = summonerId ? @"rootVC" : @"signInVC";
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                      instantiateViewControllerWithIdentifier:initialVCID];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

@end
