//
//  TAPStatsViewController.m
//  LemonNotes
//
//  Created by Christopher Fu on 12/20/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import "TAPTeammateInfoViewController.h"
#import "TAPDataManager.h"
#import "TAPSummonerManager.h"

@interface TAPTeammateInfoViewController ()

@property NSMutableArray *mostPlayedChampions;
@property NSMutableArray *mostPlayedChampionsKda;
@property NSArray *teammateStats;

@end

@implementation TAPTeammateInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Array setup with magic numbers D:<
    self.mostPlayedChampions = [[NSMutableArray alloc] init];
    self.mostPlayedChampionsKda = [[NSMutableArray alloc] init];
    self.teammateStats = [self buildStats];
    NSLog(@"%@", self.teammateStats);
    for (int i = 0; i < 4; i++)
    {
        [self.mostPlayedChampions addObject:@-1];
        [self.mostPlayedChampionsKda addObject:[NSMutableArray arrayWithArray:@[@0, @0, @0]]];
    }

    for (int i = 0; i < self.teammateRecentMatches.count; i++)
    {
        if (((NSArray *)(self.teammateRecentMatches[i])).count > 0)
        {
            self.mostPlayedChampions[i] = [self mostPlayedChampionForTeammate:i];
            NSDictionary *mostPlayedChampionStats = self.teammateStats[i][self.mostPlayedChampions[i]];
            self.mostPlayedChampionsKda[i][0] = mostPlayedChampionStats[@"kills"];
            self.mostPlayedChampionsKda[i][1] = mostPlayedChampionStats[@"deaths"];
            self.mostPlayedChampionsKda[i][2] = mostPlayedChampionStats[@"assists"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @return the id of the most played champion for the specified teammate.
 */
- (NSString *)mostPlayedChampionForTeammate:(int)teammateIndex
{
    NSDictionary *stats = self.teammateStats[teammateIndex];
    if ([stats allKeys].count == 0)
    {
        return @"";
    }
    int max = 0;
    NSString *mostPlayedChampion = @"";
    for (NSString *championId in stats)
    {
        if (((NSNumber *)stats[championId][@"games"]).intValue > max)
        {
            max = ((NSNumber *)stats[championId][@"games"]).intValue;
            mostPlayedChampion = championId;
        }
    }
    return mostPlayedChampion;
}

/**
 * NSArray of NSDictionaries (one per summoner)
 * NSDictionary compiles stats for each summoner
 * @{
 *      @"1": @{@"wins": 10, @"games": 20, @"kills": 100, @"deaths": 100, @"assists": 100, @"cs": 100},
 * }
 */
- (NSArray *)buildStats
{
    NSMutableArray *stats = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.teammateRecentMatches.count; i ++)
    {
        NSMutableDictionary *playerStats = [[NSMutableDictionary alloc] init];
        for (NSDictionary *match in self.teammateRecentMatches[i])
        {
            int summonerIndex = [match[@"summonerIndex"] intValue];
            NSDictionary *info = match[@"participants"][summonerIndex];
            NSString *champion = [info[@"championId"] stringValue];
            NSDictionary *stats = info[@"stats"];

            BOOL winner = [stats[@"winner"] boolValue];
            int kills   = ((NSNumber *)stats[@"kills"]).intValue;
            int deaths  = ((NSNumber *)stats[@"deaths"]).intValue;
            int assists = ((NSNumber *)stats[@"assists"]).intValue;
            int cs      = ((NSNumber *)stats[@"minionsKilled"]).intValue;

            if (playerStats[champion] == nil)
            {
                playerStats[champion] = [NSMutableDictionary dictionaryWithDictionary:
                                         @{@"wins": winner ? @1 : @0,
                                           @"games": @1,
                                           @"kills": [NSNumber numberWithInt:kills],
                                           @"deaths": [NSNumber numberWithInt:deaths],
                                           @"assists": [NSNumber numberWithInt:assists],
                                           @"cs": [NSNumber numberWithInt:cs]}];
            }
            else
            {
                if (winner)
                {
                    playerStats[champion][@"wins"] = [NSNumber numberWithInt:([playerStats[champion][@"wins"] intValue] + 1)];
                }
                playerStats[champion][@"games"] = [NSNumber numberWithInt:([playerStats[champion][@"games"] intValue] + 1)];
                playerStats[champion][@"kills"] = [NSNumber numberWithInt:([playerStats[champion][@"kills"] intValue] + kills)];
                playerStats[champion][@"deaths"] = [NSNumber numberWithInt:([playerStats[champion][@"deaths"] intValue] + deaths)];
                playerStats[champion][@"assists"] = [NSNumber numberWithInt:([playerStats[champion][@"assists"] intValue] + assists)];
                playerStats[champion][@"cs"] = [NSNumber numberWithInt:([playerStats[champion][@"cs"] intValue] + cs)];
            }
            NSLog(@"winner: %d, kills: %d, deaths: %d, assists: %d", winner, kills, deaths, assists);
        }
        stats[i] = playerStats;
    }
    return [NSArray arrayWithArray:stats];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teammateRecentMatches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teammateInfoCell" forIndexPath:indexPath];

    TAPDataManager *dataManager = [TAPDataManager sharedManager];

    // Configure the cell...
    UILabel *name = (UILabel *)([cell viewWithTag:100]);
    UIImageView *mostPlayedImageView = (UIImageView *)([cell viewWithTag:101]);
    UILabel *mostPlayedLabel = (UILabel *)([cell viewWithTag:102]);
    UILabel *mostPlayedKda = (UILabel *)([cell viewWithTag:103]);

    if (![self.teammateManagers[indexPath.row] isEqual:[NSNull null]])
    {
        name.text = ((TAPSummonerManager *)self.teammateManagers[indexPath.row]).summonerInfo[@"name"];
    }
    mostPlayedImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"key"]]];
    mostPlayedLabel.text = dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"name"];
    if (((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][1]).intValue != 0)
    {
        mostPlayedKda.text = [NSString stringWithFormat:@"%.2f:1",
                              (((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][0]).floatValue +
                               ((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][2]).floatValue) /
                              ((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][1]).floatValue];
    }
    else
    {
        mostPlayedKda.text = [NSString stringWithFormat:@"%.2f:1",
                              (((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][0]).floatValue +
                               ((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][2]).floatValue) /
                              (((NSNumber *)self.mostPlayedChampionsKda[indexPath.row][1]).floatValue + 1)];
    }


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showTeammateDetail" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTeammateDetail"])
    {
        
    }
}


@end
