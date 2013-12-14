//
//  Comment.h
//  DianDianEr
//
//  Created by 王超 on 13-11-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Reply, Share;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString  *c_content;
@property (nonatomic, retain) NSDate    *c_date;
@property (nonatomic, retain) NSString  *c_id;
@property (nonatomic, retain) NSString  *c_user_id;
@property (nonatomic, retain) NSString  *share_id;
@property (nonatomic, retain) NSSet     *commentToReply;
@property (nonatomic, retain) Share     *commentToShare;
@end

@interface Comment (CoreDataGeneratedAccessors)

- (void)addCommentToReplyObject:(Reply *)value;
- (void)removeCommentToReplyObject:(Reply *)value;
- (void)addCommentToReply:(NSSet *)values;
- (void)removeCommentToReply:(NSSet *)values;

@end
