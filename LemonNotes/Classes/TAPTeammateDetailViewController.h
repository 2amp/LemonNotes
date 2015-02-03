//
//  TAPTeammateDetailViewController.h
//  
//
//  Created by Christopher Fu on 1/30/15.
//
//

#import <UIKit/UIKit.h>
#import <CorePlot/CorePlot-CocoaTouch.h>

@interface TAPTeammateDetailViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (weak, nonatomic) IBOutlet UILabel *champLabel;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property NSDictionary *teammateStats;


@end
