//
//  Singleton.h
//  UploadSample
//
//  Created by Lewis on 13-10-24.
//  Copyright (c) 2013年 www.lanou3g.com  北京蓝鸥科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

@property (nonatomic ,copy) NSString *url;
@property (nonatomic ,assign) BOOL isUploading;
@property (nonatomic ,assign) BOOL isDownloading;
@property (nonatomic ,assign) BOOL isTransforming;
@property (nonatomic ,assign) BOOL fromCamera;
@property (nonatomic ,assign) BOOL fromTuYa;
@property (nonatomic ,assign) BOOL fromRecord;
@property (nonatomic,assign) BOOL isCharting;
@property (nonatomic,copy) NSString *chartingPerson;
@property (nonatomic,assign) BOOL mapInRight;
@property (nonatomic,assign) BOOL isUploadingComment;
@property (nonatomic,assign) BOOL isUploadingShare;
@property (nonatomic,assign) BOOL isUploadingReply;
@property (nonatomic,assign) BOOL isUploadingGood;
//@property (nonatomic,assign) BOOL is

+ (Singleton *)instance;

@end
