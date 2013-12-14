//
//  ShareModel.m
//  DianDianEr
//
//  Created by 信徒 on 13-11-5.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "ShareModel.h"

@implementation ShareModel

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        _s_content = [dic objectForKey:@"s_content"];
        _s_createdate = [dic objectForKey:@"s_content"];
        _s_id = [[dic objectForKey:@"s_content"] intValue];
        _s_image_url = [dic objectForKey:@"s_content"];
        _s_latitude = [[dic objectForKey:@"s_content"] doubleValue];
        _s_longitude = [[dic objectForKey:@"s_content"] doubleValue];
        _s_sound_url = [dic objectForKey:@"s_content"];
        _s_user_id = [[dic objectForKey:@"s_content"] intValue];
    }
    return self;
}

@end
