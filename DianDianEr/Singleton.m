//
//  Singleton.m
//  UploadSample
//
//  Created by Lewis on 13-10-24.
//  Copyright (c) 2013年 www.lanou3g.com  北京蓝鸥科技有限公司. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

static Singleton *s_Singleton = nil;
+ (Singleton *)instance
{
    @synchronized(self)
    {
        if (s_Singleton == nil) {
            s_Singleton = [[Singleton alloc] init];
        }
    }
    return s_Singleton;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isUploading = NO;
        self.isDownloading = NO;
        self.isTransforming = NO;
        self.fromCamera = NO;
        self.fromTuYa = NO;
        self.fromRecord = NO;
        self.isCharting = NO;
        self.chartingPerson = @"";
        self.mapInRight = YES;
        self.isUploadingComment = NO;
        self.isUploadingShare = NO;
        self.isUploadingReply = NO;
        self.isUploadingGood = NO;
    }
    return self;
}
@end
