//
//  Change.h
//  DianDianEr
//
//  Created by 王超 on 13-10-29.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Change : Share

@property (nonatomic,retain) UIImage *shareImage;
@property (nonatomic,retain) NSString *shareText;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) UIImage *userImage;
@property (nonatomic,assign) CGFloat height;


- (BOOL)hasImage;

- (CGFloat)heightForFont:(UIFont *)font WithWidth:(CGFloat)width;


@end
