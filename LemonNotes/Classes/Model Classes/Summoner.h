//
//  Summoner.h
//  LemonNotes
//
//  Created by Christopher Fu on 11/7/14.
//  Copyright (c) 2014 2AM Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Match;

@interface Summoner : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * lastMatchId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSSet *matches;
@end

@interface Summoner (CoreDataGeneratedAccessors)

- (void)addMatchesObject:(Match *)value;
- (void)removeMatchesObject:(Match *)value;
- (void)addMatches:(NSSet *)values;
- (void)removeMatches:(NSSet *)values;

@end
