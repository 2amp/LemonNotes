//
//  TAPStartGameViewController.h
//  LemonNotes
//
//  Created by Christopher Fu on 10/23/14.
//  Copyright (c) 2014 2 AM Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Class: TAPStartGameViewController
 * Type:
 * --------------------------
 * After the user has signed in, asks the user for information about the current
 * game such as the player's side, whether or not the player is the team 
 * captain, and who his teammates are.
 *
 * summonerName and idNumber are passed in by the sign in view controller before
 * the segue.
 */

@interface TAPStartGameViewController : UIViewController

@property (nonatomic) NSString *summonerName;
@property (nonatomic) NSNumber *idNumber;

@property (weak, nonatomic) IBOutlet UILabel *summonerNameLabel;

@end
