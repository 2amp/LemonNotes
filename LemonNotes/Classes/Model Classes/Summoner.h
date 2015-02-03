//
//  Summoner.h
//  LemonNotes
//
//  Created by Bohui Moon on 1/31/15.
//  Copyright (c) 2015 2AM Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Match;

@interface Summoner : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSOrderedSet *matches;
@end

@interface Summoner (CoreDataGeneratedAccessors)

- (void)insertObject:(Match *)value inMatchesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMatchesAtIndex:(NSUInteger)idx;
- (void)insertMatches:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMatchesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMatchesAtIndex:(NSUInteger)idx withObject:(Match *)value;
- (void)replaceMatchesAtIndexes:(NSIndexSet *)indexes withMatches:(NSArray *)values;
- (void)addMatchesObject:(Match *)value;
- (void)removeMatchesObject:(Match *)value;
- (void)addMatches:(NSOrderedSet *)values;
- (void)removeMatches:(NSOrderedSet *)values;
@end
