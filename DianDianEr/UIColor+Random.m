//
//  UIColor+Random.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor
{
    CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}


+ (UIColor *)customBlue //1  蓝
{
    CGFloat red =  0 / 255.0f;
	CGFloat green = 123 /  255.0f;
	CGFloat blue = 187 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customGreen // 2 绿
{
    CGFloat red =  86/ 255.0f;
	CGFloat green = 241 /  255.0f;
	CGFloat blue = 0 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customPurple // 3 紫
{
    CGFloat red =  55/ 255.0f;
	CGFloat green = 0 /  255.0f;
	CGFloat blue = 116 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customPurple2  // 4 紫2
{
    CGFloat red =  113/ 255.0f;
	CGFloat green = 0 /  255.0f;
	CGFloat blue = 228 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customCayn  //5 青
{
    CGFloat red =  118/ 255.0f;
	CGFloat green = 125 /  255.0f;
	CGFloat blue = 0 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customPurple3 // 6 紫3
{
    CGFloat red =  175/ 255.0f;
	CGFloat green = 0 /  255.0f;
	CGFloat blue = 202 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customOranger // 7 黄
{
    CGFloat red =  251/ 255.0f;
	CGFloat green = 251 /  255.0f;
	CGFloat blue = 0 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customBlack  //8 黑
{
    CGFloat red =  5/ 255.0f;
	CGFloat green = 0 /  255.0f;
	CGFloat blue = 5 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)customWhite  //9 白
{
    CGFloat red =  254/ 255.0f;
	CGFloat green = 255 /  255.0f;
	CGFloat blue = 235 /  255.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}


@end
