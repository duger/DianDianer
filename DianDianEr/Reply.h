//
//  Reply.h
//  DianDianEr
//
//  Created by 王超 on 13-11-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment;

@interface Reply : NSManagedObject

@property (nonatomic, retain) NSString * r_content;
@property (nonatomic, retain) NSDate   * r_date;
@property (nonatomic, retain) NSString * r_from_id;
@property (nonatomic, retain) NSString * r_id;
@property (nonatomic, retain) NSString * r_to_id;
@property (nonatomic, retain) NSString * r_comment_id;
@property (nonatomic, retain) Comment *replyToComment;

@end
