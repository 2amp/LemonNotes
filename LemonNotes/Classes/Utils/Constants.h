
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
#define baseURL @"https://na.api.pvp.net"

//static-data
#define staticDataURL baseURL "/api/lol/static-data/%@/v1.2/"
static NSString* kLoLStaticDataChampionList = staticDataURL @"champion"         apiKey;
static NSString* kLoLStaticDataChampionId   = staticDataURL @"champion/%@"      apiKey;
static NSString* kLoLStaticDataItemList     = staticDataURL @"item"             apiKey;
static NSString* kLoLStaticDataItemId       = staticDataURL @"item/%@"          apiKey;
static NSString* kLoLStaticDataMasteryList  = staticDataURL @"mastery"          apiKey;
static NSString* kLoLStaticDataMasteryId    = staticDataURL @"mastery/%@"       apiKey;
static NSString* kLoLStaticDataRuneList     = staticDataURL @"rune"             apiKey;
static NSString* kLoLStaticDataRuneId       = staticDataURL @"rune/%@"          apiKey;
static NSString* kLoLStaticDataSpellList    = staticDataURL @"summoner-spell"   apiKey;
static NSString* kLoLStaticDataSpellId      = staticDataURL @"summoner-spell/%@"apiKey;

//summoner
#define summonerURL baseURL "/api/lol/%@/v1.4/summoner/"
static NSString* kLoLSummonerByName         = summonerURL   @"by-name/%@"       apiKey;
static NSString* kLoLSummoner               = summonerURL   @"%@"               apiKey;
static NSString* kLoLSummonerNames          = summonerURL   @"%@/name"          apiKey;
static NSString* kLoLSummonerMasteries      = summonerURL   @"%@/masteries"     apiKey;
static NSString* kLoLSummonerRunes          = summonerURL   @"%@/runes"         apiKey;

#endif
