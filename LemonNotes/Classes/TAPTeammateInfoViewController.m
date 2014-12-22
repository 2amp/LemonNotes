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

@end

@implementation TAPTeammateInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mostPlayedChampions = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < self.teammateRecentMatches.count; i++)
    {
        self.mostPlayedChampions[i] = [self mostPlayedChampionForTeammate:i];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teammateInfoCell" forIndexPath:indexPath];

    DataManager *dataManager = [DataManager sharedManager];

    // Configure the cell...
    UILabel *name = (UILabel *)([cell viewWithTag:100]);
    UIImageView *mostPlayedImageView = (UIImageView *)([cell viewWithTag:101]);
    UILabel *mostPlayedLabel = (UILabel *)([cell viewWithTag:102]);

    name.text = ((SummonerManager *)self.teammateManagers[indexPath.row]).summonerInfo[@"name"];
    mostPlayedImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"key"]]];
    mostPlayedLabel.text = dataManager.champions[self.mostPlayedChampions[indexPath.row]][@"name"];

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
