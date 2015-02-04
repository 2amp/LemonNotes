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

@interface TAPTeammateDetailViewController ()

@end

@implementation TAPTeammateDetailViewController

- (void)viewDidLoad
{
//    NSArray *firstFiveChampions;
    NSMutableArray *xLabels = [[NSMutableArray alloc] init];
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
//    if (self.teammateStats.count >= 5)
//    {
//        firstFiveChampions = [self.teammateStats.allKeys subarrayWithRange:NSMakeRange(0, 5)];
//    }
//    else
//    {
//        firstFiveChampions = self.teammateStats.allKeys;
//    }

    for (NSString *championId in self.teammateStats.allKeys)
    {
        [xLabels addObject:[TAPDataManager sharedManager].champions[championId][@"name"]];
        [yValues addObject:self.teammateStats[championId][@"games"]];
    }

    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 20,
                                                                [UIScreen mainScreen].bounds.size.width, 200)];
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString *labelText = [NSString stringWithFormat:@"%1.f", yValueParsed];
        return labelText;
    };
    self.barChart.labelMarginTop = 5.0;
    self.barChart.xLabels = xLabels;
    self.barChart.rotateForXAxisText = true ;
    self.barChart.yValues = yValues;
//    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen]];
    // Adding gradient
//    self.barChart.barColorGradientStart = [UIColor blueColor];

    [self.barChart strokeChart];

    self.barChart.delegate = self;

    [self.view addSubview:self.barChart];
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
