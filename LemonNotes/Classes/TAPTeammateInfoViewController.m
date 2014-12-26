//
//  TAPStatsViewController.m
//  LemonNotes
//
//  Created by Christopher Fu on 12/20/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import "TAPTeammateInfoViewController.h"
#import "DataManager.h"
#import "SummonerManager.h"

@interface TAPTeammateInfoViewController ()

@property NSMutableArray *mostPlayedChampions;
@property NSMutableArray *mostPlayedChampionsKda;

@end

@implementation TAPTeammateInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Array setup with magic numbers D:<
    self.mostPlayedChampions = [[NSMutableArray alloc] init];
    self.mostPlayedChampionsKda = [[NSMutableArray alloc] init];
    for (int i = 0; i < 4; i++)
    {
        [self.mostPlayedChampions addObject:[NSNumber numberWithInt:-1]];
        [self.mostPlayedChampionsKda addObject:[NSMutableArray arrayWithArray:@[[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0]]]];
    }

    for (int i = 0; i < self.teammateRecentMatches.count; i++)
    {
        if (((NSArray *)(self.teammateRecentMatches[i])).count > 0)
        {
            self.mostPlayedChampions[i] = [self mostPlayedChampionForTeammate:i];
            for (NSDictionary *match in self.teammateRecentMatches[i])
            {
                int summonerIndex = [match[@"summonerIndex"] intValue];
                NSDictionary *info = match[@"participants"][summonerIndex];
                if ([[info[@"championId"] stringValue] isEqualToString:self.mostPlayedChampions[i]])
                {
                    NSDictionary *stats = info[@"stats"];
                    int kills   = ((NSNumber *)stats[@"kills"]).intValue;
                    int deaths  = ((NSNumber *)stats[@"deaths"]).intValue;
                    int assists = ((NSNumber *)stats[@"assists"]).intValue;
                    self.mostPlayedChampionsKda[i][0] = [NSNumber numberWithInt:(((NSNumber *)self.mostPlayedChampionsKda[i][0]).intValue + kills)];
                    self.mostPlayedChampionsKda[i][1] = [NSNumber numberWithInt:(((NSNumber *)self.mostPlayedChampionsKda[i][1]).intValue + deaths)];
                    self.mostPlayedChampionsKda[i][2] = [NSNumber numberWithInt:(((NSNumber *)self.mostPlayedChampionsKda[i][2]).intValue + assists)];
                }
            }
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
- (NSNumber *)mostPlayedChampionForTeammate:(int)teammateIndex
{
    NSMutableArray *championsPlayed = [[NSMutableArray alloc] init];
    for (NSDictionary *match in self.teammateRecentMatches[teammateIndex])
    {
        int summonerIndex = [match[@"summonerIndex"] intValue];
        NSDictionary *info  = match[@"participants"][summonerIndex];
        [championsPlayed addObject:[info[@"championId"] stringValue]];
    }
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:championsPlayed];
    NSNumber *mostPlayedChampion;
    NSUInteger max = 0;
    for (NSNumber *championId in countedSet)
    {
        if ([countedSet countForObject:championId] > max)
        {
            max = [countedSet countForObject:championId];
            mostPlayedChampion = championId;
        }
    }
    return mostPlayedChampion;
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
    NSLog(@"tableView:cellForRowAtIndexPath:");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teammateInfoCell" forIndexPath:indexPath];

    DataManager *dataManager = [DataManager sharedManager];

    // Configure the cell...
    UILabel *name = (UILabel *)([cell viewWithTag:100]);
    UIImageView *mostPlayedImageView = (UIImageView *)([cell viewWithTag:101]);
    UILabel *mostPlayedLabel = (UILabel *)([cell viewWithTag:102]);
    UILabel *mostPlayedKda = (UILabel *)([cell viewWithTag:103]);

    if (![self.teammateManagers[indexPath.row] isEqual:[NSNull null]])
    {
        name.text = ((SummonerManager *)self.teammateManagers[indexPath.row]).summonerInfo[@"name"];
    }
    mostPlayedImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"key"]]];
    mostPlayedLabel.text = dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"name"];
    mostPlayedKda.text = [NSString stringWithFormat:@"%@/%@/%@", self.mostPlayedChampionsKda[indexPath.row][0], self.mostPlayedChampionsKda[indexPath.row][1],
                          self.mostPlayedChampionsKda[indexPath.row][2]];

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
