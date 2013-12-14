//
//  ChartList.h
//  DianDianEr
//
//  Created by Duger on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Messages;

@interface ChartList : NSManagedObject

@property (nonatomic, retain) NSString * chartList_id;
@property (nonatomic, retain) NSNumber * total_num;
@property (nonatomic, retain) NSNumber * unread_num;
@property (nonatomic, retain) NSString * user_jid;
@property (nonatomic, retain) NSOrderedSet *chartListToMessages;
@end

@interface ChartList (CoreDataGeneratedAccessors)

- (void)insertObject:(Messages *)value inChartListToMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChartListToMessagesAtIndex:(NSUInteger)idx;
- (void)insertChartListToMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChartListToMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChartListToMessagesAtIndex:(NSUInteger)idx withObject:(Messages *)value;
- (void)replaceChartListToMessagesAtIndexes:(NSIndexSet *)indexes withChartListToMessages:(NSArray *)values;
- (void)addChartListToMessagesObject:(Messages *)value;
- (void)removeChartListToMessagesObject:(Messages *)value;
- (void)addChartListToMessages:(NSOrderedSet *)values;
- (void)removeChartListToMessages:(NSOrderedSet *)values;
@end
