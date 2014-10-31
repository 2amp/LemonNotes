
/**
 * @header Constants.h
 *
 * Defines all the Riot API URL call patterns as constants.
 * Provides convenient static C function to get API URL
 * using one of the defined patterns and other params.
 */
#ifndef LemonNotes_Constants_h
#define LemonNotes_Constants_h

///apiKey should be defined individually
#import "apikeys.h"

//riot api urls
#define baseURL @"https://{region}.api.pvp.net"

//champion
#define pathChampion baseURL "/api/lol/{region}/v1.2/champion"
static NSString* kLoLChampionList           = pathChampion ""                   apiKey;
static NSString* kLoLChampion               = pathChampion "/%@"                apiKey; //{id}

//game
#define pathGame baseURL "/api/lol/{region}/v1.3/game/by-summoner"
static NSString* kLoLGameBySummoner         = pathGame  "/%@/recent"            apiKey; //{summonerId}

//league
#define pathLeague baseURL "/api/lol/{region}/v2.5/league"
static NSString* kLoLLeagueSummoner         = pathLeague "/by-summoner/%@"      apiKey; //{summonerIds}
static NSString* kLoLLeagueSummonerEntry    = pathLeague "/by-summoner/%@/entry"apiKey; //{summonerIds}
static NSString* kLoLLeagueTeam             = pathLeague "/by-team/%@"          apiKey; //{summonerIds}
static NSString* kLoLLeagueTeamEntry        = pathLeague "/by-team/%@/entry"    apiKey; //{summonerIds}
static NSString* kLoLLeagueChallenger       = pathLeague "/challenger"          apiKey; //{summonerIds}

//static-data
#define pathStaticData baseURL "/api/lol/static-data/{region}/v1.2"
static NSString* kLoLStaticDataChampionList = pathStaticData "/champion"         apiKey;
static NSString* kLoLStaticDataChampion     = pathStaticData "/champion/%@"      apiKey; //{id}
static NSString* kLoLStaticDataItemList     = pathStaticData "/item"             apiKey;
static NSString* kLoLStaticDataItem         = pathStaticData "/item/%@"          apiKey; //{id}
static NSString* kLoLStaticDataMasteryList  = pathStaticData "/mastery"          apiKey;
static NSString* kLoLStaticDataMastery      = pathStaticData "/mastery/%@"       apiKey; //{id}
static NSString* kLoLStaticDataRuneList     = pathStaticData "/rune"             apiKey;
static NSString* kLoLStaticDataRune         = pathStaticData "/rune/%@"          apiKey;
static NSString* kLoLStaticDataSpellList    = pathStaticData "/summoner-spell"   apiKey;
static NSString* kLoLStaticDataSpell        = pathStaticData "/summoner-spell/%@"apiKey;

//status
#define pathStatus baseURL "/shards"
static NSString* kLoLStatus                 = pathStatus    ""                  apiKey;
static NSString* kLoLStatusRegion           = pathStatus    "/%@"               apiKey; //{region}

//match
#define pathMatch baseURL "/api/lol/{region}/v2.2"
static NSString* kLoLMatch                  = pathMatch      "/%@"              apiKey; //{matchId}

//match history
#define pathMatchHistory baseURL "/api/lol/{region}/v2.2/matchhistory"
static NSString* kLoLMatchHistory           = pathMatchHistory "/%@"            apiKey; //{summonerId}

//stats
#define pathStats baseURL "/api/lol/{region}/v1.3/stats/by-summoner"
static NSString* kLoLStatsRanked            = pathStats "/%@/ranked"            apiKey; //{summonerId}
static NSString* kLoLStatsSummary           = pathStats "/%@/ranked"            apiKey; //{summonerId}

//summoner
#define pathSummoner baseURL "/api/lol/{region}/v1.4/summoner"
static NSString* kLoLSummonerByName         = pathSummoner  "/by-name/%@"       apiKey; //{summonerName}
static NSString* kLoLSummoner               = pathSummoner  "/%@"               apiKey; //{summonerId}
static NSString* kLoLSummonerNames          = pathSummoner  "/%@/name"          apiKey; //{summonerId}
static NSString* kLoLSummonerMasteries      = pathSummoner  "/%@/masteries"     apiKey; //{summonerId}
static NSString* kLoLSummonerRunes          = pathSummoner  "/%@/runes"         apiKey; //{summonerId}

//team
#define pathTeam baseURL "/api/lol/{region}/v2.4/team"
static NSString* kLoLTeamBySummoner         = pathTeam      "/by-summoner/%@"   apiKey; //{summonerIds}
static NSString* kLoLTeam                   = pathTeam      "/%@"               apiKey; //{teamIds}



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
 * @param call   - one of the predefined call formats
 * @param region - region of API call
 * @param param  - any parameters to pass in API call
 * @return NSURL object with correct API call with given params
 */
static inline NSURL* apiURL(NSString *call, NSString *region, NSString *param)
{
    NSString *format = [call stringByReplacingOccurrencesOfString:@"{region}" withString:region];
    NSString *urlStr = [NSString stringWithFormat:format, param];
    
    return [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#endif
