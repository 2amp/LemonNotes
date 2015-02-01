//
//  TAPTeammateDetailViewController.m
//  
//
//  Created by Christopher Fu on 1/30/15.
//
//

#import "TAPTeammateDetailViewController.h"

const int STATUS_BAR_HEIGHT = 20;
const int NAVIGATION_BAR_HEIGHT = 44;
const int TAB_BAR_HEIGHT = 49;

@interface TAPTeammateDetailViewController ()

@end

@implementation TAPTeammateDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-4)
                                                    length:CPTDecimalFromFloat(8)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(16)];
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    plot.dataSource = self;
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 9;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    int x = (int)idx - 4;
    if (fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithInt:x];
    }
    else
    {
        return [NSNumber numberWithInt:(x * x)];
    }
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
