//
//  Share.h
//  DianDianEr
//
//  Created by 王超 on 13-11-19.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Good;

@interface Share : NSManagedObject

@property (nonatomic, retain) NSString *s_content;
@property (nonatomic, retain) NSDate   *s_createdate;
@property (nonatomic, retain) NSNumber *s_hot;
@property (nonatomic, retain) NSString *s_id;
@property (nonatomic, retain) NSString *s_image_url;
@property (nonatomic, retain) NSNumber *s_latitude;
@property (nonatomic, retain) NSString *s_locationName;
@property (nonatomic, retain) NSNumber *s_longitude;
@property (nonatomic, retain) NSString *s_sound_url;
@property (nonatomic, retain) NSString *s_user_id;
@property (nonatomic, retain) NSSet    *shareToComment;
@property (nonatomic, retain) NSSet    *shareToGood;
@end

@interface Share (CoreDataGeneratedAccessors)

- (void)addShareToCommentObject:(Comment *)value;
- (void)removeShareToCommentObject:(Comment *)value;
- (void)addShareToComment:(NSSet *)values;
- (void)removeShareToComment:(NSSet *)values;

- (void)addShareToGoodObject:(Good *)value;
- (void)removeShareToGoodObject:(Good *)value;
- (void)addShareToGood:(NSSet *)values;
- (void)removeShareToGood:(NSSet *)values;

@end
