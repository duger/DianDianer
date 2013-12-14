//
//  Friendlist.h
//  DianDianEr
//
//  Created by Duger on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Friendlist : NSManagedObject

@property (nonatomic, retain) NSNumber * f_id;
@property (nonatomic, retain) NSString * f_relationship_hot;
@property (nonatomic, retain) NSString * f_user_id;
@property (nonatomic, retain) User *firendToUser;

@end
