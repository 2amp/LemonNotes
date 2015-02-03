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

const CGFloat BAR_WIDTH = 0.25f;
const CGFloat BAR_INITIAL_X = 0.25f;

@interface TAPTeammateDetailViewController ()

@end

@implementation TAPTeammateDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPlot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPlot
{
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

- (void)configureGraph
{
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft = 30.0f;
    graph.paddingTop = -1.0f;
    graph.paddingRight = -5.0f;
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    NSString *title = @"Portfolio Prices";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    CGFloat xMin = 0.0f;
    CGFloat xMax = 5.0f;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 800.0f;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

- (void)configurePlots
{
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.identifier = @"AAPL";
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = BAR_INITIAL_X;
    barPlot.dataSource = self;
    barPlot.delegate = self;
    barPlot.barWidth = CPTDecimalFromDouble(BAR_WIDTH);
    barPlot.barOffset = CPTDecimalFromDouble(barX);
    barPlot.lineStyle = barLineStyle;
    [graph addPlot:barPlot toPlotSpace:graph.defaultPlotSpace];
}

- (void)configureAxes
{
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"Days of Week (Mon - Fri)";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = @"Price";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 5;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if (fieldEnum == CPTBarPlotFieldBarTip)
    {
        return @400;
    }
    else
    {
        return [NSDecimalNumber numberWithUnsignedInteger:idx];
    }
}

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{

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
