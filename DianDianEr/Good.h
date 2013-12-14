//
//  Good.h
//  DianDianEr
//
//  Created by Duger on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Share;

@interface Good : NSManagedObject

@property (nonatomic, retain) NSNumber * g_id;
@property (nonatomic, retain) NSString * g_type;
@property (nonatomic, retain) NSString * g_user_id;
@property (nonatomic, retain) Share *goodToShare;

@end
