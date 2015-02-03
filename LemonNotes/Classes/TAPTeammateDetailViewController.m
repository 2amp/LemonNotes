//
//  TAPTeammateDetailViewController.m
//  
//
//  Created by Christopher Fu on 1/30/15.
//
//

#import "TAPTeammateDetailViewController.h"
#import <PNChart/PNColor.h>

const int STATUS_BAR_HEIGHT = 20;
const int NAVIGATION_BAR_HEIGHT = 44;
const int TAB_BAR_HEIGHT = 49;

@interface TAPTeammateDetailViewController ()

@end

@implementation TAPTeammateDetailViewController

- (void)viewDidLoad
{
    for (NSString *championId in self.teammateStats.allKeys)
    {
        NSLog(@"%@", championId);
    }

    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT,
                                                                [UIScreen mainScreen].bounds.size.width, 200)];
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString *labelText = [NSString stringWithFormat:@"%1.f", yValueParsed];
        return labelText;
    };
    self.barChart.labelMarginTop = 5.0;
    [self.barChart setXLabels:@[@"Lucian",@"Caitlyn",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    self.barChart.rotateForXAxisText = true ;
    [self.barChart setYValues:@[@1,@24,@12,@18,@30,@10,@21]];
    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen,PNYellow,PNGreen]];
    // Adding gradient
    self.barChart.barColorGradientStart = [UIColor blueColor];

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
