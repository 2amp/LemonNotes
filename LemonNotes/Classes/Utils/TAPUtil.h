

#ifndef LemonNotes_TAPUtil_h
#define LemonNotes_TAPUtil_h

#pragma mark - Riot LoL API
///apiKey should be defined individually
#import "apikeys.h"

//riot api urls
static NSString* baseURL = @"https://{server}.api.pvp.net";

//champion
#define pathChampion @"api/lol/{region}/v1.2/champion"
static NSString* kLoLChampionList        = pathChampion "";
static NSString* kLoLChampion            = pathChampion "/{path}";                 //{id}

//game
#define pathGame @"api/lol/{region}/v1.3/game/by-summoner"
static NSString* kLoLGameBySummoner      = pathGame  "/{path}/recent";             //{summonerId}

//league
#define pathLeague @"api/lol/{region}/v2.5/league"
static NSString* kLoLLeagueSummoner      = pathLeague "/by-summoner/{path}";       //{summonerIds}
static NSString* kLoLLeagueSummonerEntry = pathLeague "/by-summoner/{path}/entry"; //{summonerIds}
static NSString* kLoLLeagueTeam          = pathLeague "/by-team/{path}";           //{summonerIds}
static NSString* kLoLLeagueTeamEntry     = pathLeague "/by-team/{path}/entry";     //{summonerIds}
static NSString* kLoLLeagueChallenger    = pathLeague "/challenger";               //{summonerIds}

//static-data
#define pathStatic @"api/lol/static-data/{region}/v1.2"
static NSString* kLoLStaticChampionList  = pathStatic "/champion";
static NSString* kLoLStaticChampion      = pathStatic "/champion/{path}";    //{id}
static NSString* kLoLStaticItemList      = pathStatic "/item";
static NSString* kLoLStaticItem          = pathStatic "/item/{path}";        //{id}
static NSString* kLoLStaticMasteryList   = pathStatic "/mastery";
static NSString* kLoLStaticMastery       = pathStatic "/mastery/{path}";     //{id}
static NSString* kLoLStaticRuneList      = pathStatic "/rune";
static NSString* kLoLStaticRune          = pathStatic "/rune/{path}";
static NSString* kLoLStaticSpellList     = pathStatic "/summoner-spell";
static NSString* kLoLStaticSpell         = pathStatic "/summoner-spell/{path}";

//status
#define pathStatus @"shards"
static NSString* kLoLStatus              = pathStatus   "";
static NSString* kLoLStatusRegion        = pathStatus   "/{path}";           //{region}

//match
#define pathMatch @"api/lol/{region}/v2.2/match"
static NSString* kLoLMatch               = pathMatch    "/{path}";           //{matchId}

//match history
#define pathMatchHistory @"api/lol/{region}/v2.2/matchhistory"
static NSString* kLoLMatchHistory     = pathMatchHistory "/{path}";          //{summonerId}

//stats
#define pathStats @"api/lol/{region}/v1.3/stats/by-summoner"
static NSString* kLoLStatsRanked         = pathStats    "/{path}/ranked";    //{summonerId}
static NSString* kLoLStatsSummary        = pathStats    "/{path}/summary";   //{summonerId}

//summoner
#define pathSummoner @"api/lol/{region}/v1.4/summoner"
static NSString* kLoLSummonerByName      = pathSummoner "/by-name/{path}";   //{summonerName}
static NSString* kLoLSummoner            = pathSummoner "/{path}";           //{summonerId}
static NSString* kLoLSummonerNames       = pathSummoner "/{path}/name";      //{summonerId}
static NSString* kLoLSummonerMasteries   = pathSummoner "/{path}/masteries"; //{summonerId}
static NSString* kLoLSummonerRunes       = pathSummoner "/{path}/runes";     //{summonerId}

//team
#define pathTeam @"api/lol/{region}/v2.4/team"
static NSString* kLoLTeamBySummoner      = pathTeam    "/by-summoner/{path}"; //{summonerIds}
static NSString* kLoLTeam                = pathTeam    "/{path}";             //{teamIds}


//image assets
#define ddragon @"https://ddragon.leagueoflegends.com/cdn"
static NSString* kLoLChampSplash = ddragon "/img/champion/splash/%@_0.jpg";
static NSString* kLoLChampIcon   = ddragon "/%@/img/champion/%@.png";
static NSString* kLoLSpellIcon   = ddragon "/%@/img/spell/%@.png";
static NSString* kLoLItemIcon    = ddragon "/%@/img/item/%@.png";


/**
 * @function apiURL
 * @breif Usage: static c function for getting Riot API URLs
 *
 * Given one of the call formats constants defined, a region, and param
 * returns a NSURL pointer with the correct API call.
 *
 * @note Caller should know whether call contains a param.
 *       Giving a param to an API call without parameters will not cause an error,
 *       but caller should pass param as nil when API call doesn't require one.
 *       Some API calls also allow for comma-separated IDs.
 *
 * @param call one of the predefined call formats
 * @param region region of API call
 * @param pathParam any path parameters to pass in API call
 * @param queryParams An NSArray of any query parameters to pass in API call, in the form of @"param=value"
 * @return NSURL object with correct API call with given params
 */
static inline NSURL* apiURL(NSString *call, NSString *region, NSString *pathParam, NSArray *queryParams)
{
    NSString *url = [NSString stringWithFormat:@"%@/%@?{query}api_key=%@", baseURL, call, API_KEY];
    
    //change server to "global" only for static-data api call
    NSString *server = [NSString stringWithString:region];
    if ([url containsString:@"static-data"])
    {
        BOOL global = [region isEqual:@"euw"] || [region isEqual:@"kr"] || [region isEqual:@"ru"] || [region isEqual:@"tr"];
        server = global ? @"global" : region;
    }
    
    //empty path param if nil
    if (!pathParam) pathParam = @"";
    
    //combine query params
    NSMutableString *queryParam = [NSMutableString stringWithString:@""];
    for (NSString *param in queryParams)
    {
        [queryParam appendString:[NSString stringWithFormat:@"%@&", param]];
    }
    
    //format url
    url = [url stringByReplacingOccurrencesOfString:@"{server}" withString:server];
    url = [url stringByReplacingOccurrencesOfString:@"{region}" withString:region];
    url = [url stringByReplacingOccurrencesOfString:@"{path}" withString:pathParam];
    url = [url stringByReplacingOccurrencesOfString:@"{query}" withString:queryParam];
    
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * @function imgURL
 *
 * Given one of the call formats, version, and key,
 * returns the url to the ddragon asset accordingly.
 *
 * @param call - path to ddragon url
 * @param ver  - version of current patch
 * @param key  - of champ/spell/item to get
 */
static inline NSURL* imgURL(NSString *call, NSString *ver, NSString *key)
{
    NSString *url = [NSString stringWithFormat:call, ver, key];
    if ([call isEqualToString:kLoLChampSplash])
        url = [NSString stringWithFormat:call, key];
    
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}



#pragma mark - Misc Static Inline Funcs
/**
 * @function showAlert
 *
 * Creates an UIAlertView object with the given title & message
 * along with self as delegate, "OK" as cancel button, and no other buttons.
 * Immediately shows the window
 */
static inline void showAlert(NSString *title, NSString *message)
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

/**
 * @function versionIsHigher
 *
 * Given two version strings (ex. "1.2.45")
 * returns whether first is higher than second.
 */
static inline BOOL versionIsHigher(NSString *newVersion, NSString *oldVersion)
{
    NSArray *newVersionParts = [newVersion componentsSeparatedByString:@"."];
    NSArray *oldVersionParts = [oldVersion componentsSeparatedByString:@"."];
    
    for (int i = 0; i < newVersionParts.count; i++)
    {
        int newVal = [newVersionParts[i] intValue];
        int oldVal = [oldVersionParts[i] intValue];
        
        if (newVal < oldVal) return NO;
        if (newVal > oldVal) return YES;
    }
    
    return NO;
}

/**
 * @function getTimeAgoWith
 *
 * Given a NSDate since Epoch of match creation time,
 * returns the English translation of how long ago the game was.
 *
 * @param dateSinceEpoch - creation date of match given since Epoch
 */
static inline NSString* getTimeAgoWith(NSDate *dateSinceEpoch)
{
    double interval = -dateSinceEpoch.timeIntervalSinceNow;
    NSString *units;
    
        //minutes
    interval /= 60;
    if (interval < 60)
    {
        units = (interval > 2) ? @"minutes" : @"minute";
        return [NSString stringWithFormat:@"%d %@ ago", (int)interval, units];
    }
    
        //hours
    interval /= 60;
    if (interval < 24)
    {
        units = (interval > 2) ? @"hours" : @"hour";
        return [NSString stringWithFormat:@"%d %@ ago", (int)interval, units];
    }
    
        //days
    interval /= 24;
    if (interval < 30)
    {
        units = (interval > 2) ? @"days" : @"day";
        return [NSString stringWithFormat:@"%d %@ ago", (int)interval, units];
    }
    
        //months
    interval /= 30;
    if (interval < 12)
    {
        units = (interval > 2) ? @"months" : @"month";
        return [NSString stringWithFormat:@"%d %@ ago", (int)interval, units];
    }
    
        //years
    interval /= 12;
    units = (interval > 2) ? @"years" : @"year";
    return [NSString stringWithFormat:@"%d %@ ago", (int)interval, units];
}

#endif
