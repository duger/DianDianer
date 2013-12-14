//
//  User.h
//  DianDianEr
//
//  Created by Duger on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friendlist;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * u_birth;
@property (nonatomic, retain) NSNumber * u_id;
@property (nonatomic, retain) NSString * u_image;
@property (nonatomic, retain) NSString * u_jid;
@property (nonatomic, retain) NSNumber * u_latitude;
@property (nonatomic, retain) NSNumber * u_longtitude;
@property (nonatomic, retain) NSString * u_name;
@property (nonatomic, retain) NSNumber * u_sex;
@property (nonatomic, retain) NSString * u_signature;
@property (nonatomic, retain) NSSet *userToFriend;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserToFriendObject:(Friendlist *)value;
- (void)removeUserToFriendObject:(Friendlist *)value;
- (void)addUserToFriend:(NSSet *)values;
- (void)removeUserToFriend:(NSSet *)values;

@end
