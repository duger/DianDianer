//
//  Messages.h
//  DianDianEr
//
//  Created by Duger on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Messages : NSManagedObject

@property (nonatomic, retain) NSString * chart_content;
@property (nonatomic, retain) NSDate * chart_date;
@property (nonatomic, retain) NSNumber * chart_state;
@property (nonatomic, retain) NSString * from_jid;
@property (nonatomic, retain) NSString * to_jid;

@end
