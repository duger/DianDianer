//
//  ShareManager.h
//  DianDianEr
//
//  Created by Duger on 13-10-28.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ShareManagerDelegate <NSObject>

- (void)changeUploadProgress:(CGFloat)progress;
- (void)setProgress:(float)progress;

@end

typedef void (^CompletionBlock)();

@interface ShareManager : NSObject<NSURLConnectionDataDelegate>
+(ShareManager *)defaultManager;

@property(nonatomic,assign) id<ShareManagerDelegate> delegate;

@property(nonatomic,retain) UIImage     *currentImage;
@property(nonatomic,copy)   NSString    *inPutSoundsPath;
@property(nonatomic,copy)   NSString    *shareContents;
@property(nonatomic,assign) double      longitude;
@property(nonatomic,assign) double      latitude;
@property(nonatomic,copy)   NSString    *inPutImagePath;
@property(nonatomic,copy)   NSString    *tempImagePath;
@property(nonatomic,copy)   NSString    *shareID;

//以下属性上传评论用的
@property(nonatomic,copy)   NSString    *commentID;
@property(nonatomic,copy)   NSString    *commentContent;
@property(nonatomic,copy)   NSString    *userID;
@property(nonatomic,retain) NSDate      *creatDate;
//上传评论数据的方法
-(void)uploadComment;

//以下属性上传回复用的
@property(nonatomic,copy)   NSString    *replyID;
@property(nonatomic,copy)   NSString    *replyContent;
@property(nonatomic,copy)   NSDate      *replyDate;
@property(nonatomic,copy)   NSString    *replyToID;
@property(nonatomic,copy)   NSString    *replyFromID;
@property(nonatomic,copy)   NSString    *replyCommentID;
//上传回复数据的方法
-(void)uploadReply;

//以下属性上传赞用的
@property(nonatomic,assign) NSNumber    *goodID;
@property(nonatomic,copy)   NSString    *goodUserID;
@property(nonatomic,copy)   NSString    *goodType;
//上传赞数据的方法
-(void)uploadGood;

//地点
@property(nonatomic,copy) NSString *locationPlace;


-(void)uploadWithCompletionBlock:(CompletionBlock) completion;

-(void)toMp3;
@end
