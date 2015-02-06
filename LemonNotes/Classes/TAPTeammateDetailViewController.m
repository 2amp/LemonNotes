//
//  TAPTeammateDetailViewController.m
//  
//
//  Created by Christopher Fu on 1/30/15.
//
//

#import "TAPTeammateDetailViewController.h"
#import "TAPDataManager.h"
#import <PNChart/PNColor.h>

const int STATUS_BAR_HEIGHT = 20;
const int NAVIGATION_BAR_HEIGHT = 44;
const int TAB_BAR_HEIGHT = 49;

const int NUM_BARS = 8;

@interface TAPTeammateDetailViewController ()

@end

@implementation TAPTeammateDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpMostPlayedBarGraph];
}

/**
 * Creates a bar graph of the NUM_BARS most played champions. Uses
 * self.barChartHolder as a placeholder view.
 */
- (void)setUpMostPlayedBarGraph
{
    // Sort champion ids according to the number of games played
    NSArray *championsSortedByGames = [self.teammateStats keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if (((NSNumber *)obj1[@"games"]).intValue > ((NSNumber *)obj2[@"games"]).intValue)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else if (((NSNumber *)obj1[@"games"]).intValue < ((NSNumber *)obj2[@"games"]).intValue)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else
        {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    NSArray *mostPlayedChampions;
    NSMutableArray *xLabels = [[NSMutableArray alloc] init];
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
    if (championsSortedByGames.count >= NUM_BARS)
    {
        mostPlayedChampions = [championsSortedByGames subarrayWithRange:NSMakeRange(0, NUM_BARS)];
    }
    else
    {
        mostPlayedChampions = championsSortedByGames;
    }

    for (NSString *championId in mostPlayedChampions)
    {
        [xLabels addObject:[TAPDataManager sharedManager].champions[championId][@"name"]];
        [yValues addObject:self.teammateStats[championId][@"games"]];
    }

    // Init PNBarChart in the placeholder parent view
    self.mostPlayedBarChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.mostPlayedBarChartHolder.frame.size.width,
                                                                 self.mostPlayedBarChartHolder.frame.size.height)];
    self.mostPlayedBarChart.backgroundColor = [UIColor clearColor];
    self.mostPlayedBarChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString *labelText = [NSString stringWithFormat:@"%1.f", yValueParsed];
        return labelText;
    };
    self.mostPlayedBarChart.labelMarginTop = 5.0;
    self.mostPlayedBarChart.xLabels = xLabels;
    self.mostPlayedBarChart.rotateForXAxisText = true ;
    self.mostPlayedBarChart.yValues = yValues;
    //    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen]];
    // Adding gradient
    //    self.barChart.barColorGradientStart = [UIColor blueColor];

    [self.mostPlayedBarChart strokeChart];

    self.mostPlayedBarChart.delegate = self;

    [self.mostPlayedBarChartHolder addSubview:self.mostPlayedBarChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
