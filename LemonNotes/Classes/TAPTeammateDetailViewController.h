//
//  TAPTeammateDetailViewController.h
//  
//
//  Created by Christopher Fu on 1/30/15.
//
//

#import <UIKit/UIKit.h>
#import <PNChart/PNBarChart.h>

@interface TAPTeammateDetailViewController : UIViewController <PNChartDelegate>

@property (weak, nonatomic) IBOutlet UILabel *champLabel;
@property PNBarChart *barChart;
@property NSDictionary *teammateStats;


@end
