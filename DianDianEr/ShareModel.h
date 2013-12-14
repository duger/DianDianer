//
//  ShareModel.h
//  DianDianEr
//
//  Created by 信徒 on 13-11-5.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareModel : NSObject

@property (nonatomic, retain) NSString * s_content;
@property (nonatomic, retain) NSString * s_createdate;
@property (nonatomic) int16_t s_id;
@property (nonatomic, retain) NSString * s_image_url;
@property (nonatomic) double s_latitude;
@property (nonatomic) double s_longitude;
@property (nonatomic, retain) NSString * s_sound_url;
@property (nonatomic) int16_t s_user_id;
@property (nonatomic, retain) NSSet *relationship;

- (id)initWithDic:(NSDictionary *)dic;
@end
