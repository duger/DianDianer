//
//  IphoneScreen.m
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-5-25.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import "IphoneScreen.h"

@implementation IphoneScreen

-(void)test{
([[[UIDevice  currentDevice]systemVersion]floatValue]>=7) ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO);
    

}
 
@end
