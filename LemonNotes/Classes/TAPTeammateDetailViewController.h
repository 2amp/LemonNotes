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
@property PNBarChart *mostPlayedBarChart;
@property NSDictionary *teammateStats;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *mostPlayedBarChartHolder;

@end
