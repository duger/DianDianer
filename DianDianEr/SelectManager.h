//
//  SelectManager.h
//  DianDianEr
//
//  Created by Duger on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Share.h"
#import "Good.h"
#import "Comment.h"
#import "Reply.h"

@protocol SelectManagerDelegate <NSObject>
-(void)changedownProgress:(CGFloat)progress;

@end

@interface SelectManager : NSObject<NSURLConnectionDataDelegate,DiandianCoreDataManagerDelegate>

@property(nonatomic,assign) id<SelectManagerDelegate> delegate;

+(SelectManager*)defaultManager;
- (NSArray *)downloadDateFromServiceToLocal:(int)flag;

-(void)downloadRecentShare;
-(void)downloadRecentGood;
-(void)downloadRecentComment;
-(void)downloadRecentReply;

@end
