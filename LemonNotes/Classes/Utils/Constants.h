
#ifndef LemonNotes_Constants_h
#define LemonNotes_Constants_h

#import "apikeys.h"

/**
 * File: Constants
 * Type: Header
 * --------------------------
 * Defines all the Riot API call URLs as constants.
 * Every URL's first param must be the region
 */

//riot api urls
#define baseURL @"https://{region}.api.pvp.net"

//static-data
#define pathStaticData baseURL "/api/lol/static-data/{region}/v1.2"
static NSString* kLoLStaticDataChampionList = pathStaticData "/champion"         apiKey;
static NSString* kLoLStaticDataChampionId   = pathStaticData "/champion/%@"      apiKey;
static NSString* kLoLStaticDataItemList     = pathStaticData "/item"             apiKey;
static NSString* kLoLStaticDataItemId       = pathStaticData "/item/%@"          apiKey;
static NSString* kLoLStaticDataMasteryList  = pathStaticData "/mastery"          apiKey;
static NSString* kLoLStaticDataMasteryId    = pathStaticData "/mastery/%@"       apiKey;
static NSString* kLoLStaticDataRuneList     = pathStaticData "/rune"             apiKey;
static NSString* kLoLStaticDataRuneId       = pathStaticData "/rune/%@"          apiKey;
static NSString* kLoLStaticDataSpellList    = pathStaticData "/summoner-spell"   apiKey;
static NSString* kLoLStaticDataSpellId      = pathStaticData "/summoner-spell/%@"apiKey;

//summoner
#define pathSummoner baseURL "/api/lol/{region}/v1.4/summoner/"
static NSString* kLoLSummonerByName         = pathSummoner "by-name/%@"       apiKey;
static NSString* kLoLSummoner               = pathSummoner "%@"               apiKey;
static NSString* kLoLSummonerNames          = pathSummoner "%@/name"          apiKey;
static NSString* kLoLSummonerMasteries      = pathSummoner "%@/masteries"     apiKey;
static NSString* kLoLSummonerRunes          = pathSummoner "%@/runes"         apiKey;


NSURL* apiURL(NSString *call, NSString *region, NSString *param)
{
    NSString *format = [call stringByReplacingOccurrencesOfString:@"{region}" withString:region];
    NSString *urlStr = [NSString stringWithFormat:format, param];
    
    return [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#endif
