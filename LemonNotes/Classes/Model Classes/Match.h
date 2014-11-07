//
//  Match.h
//  LemonNotes
//
//  Created by Christopher Fu on 11/7/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Match : NSManagedObject

@property (nonatomic, retain) NSNumber * mapId;
@property (nonatomic, retain) NSNumber * matchCreation;
@property (nonatomic, retain) NSNumber * matchDuration;
@property (nonatomic, retain) NSNumber * matchId;
@property (nonatomic, retain) NSString * matchMode;
@property (nonatomic, retain) NSString * matchType;
@property (nonatomic, retain) NSString * matchVersion;
@property (nonatomic, retain) id participantIdentities;
@property (nonatomic, retain) id participants;
@property (nonatomic, retain) NSString * platformId;
@property (nonatomic, retain) NSString * queueType;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * season;
@property (nonatomic, retain) NSNumber * summonerIndex;
@property (nonatomic, retain) id teams;
@property (nonatomic, retain) NSManagedObject *summoner;

@end
