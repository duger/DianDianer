//
//  Change.m
//  DianDianEr
//
//  Created by 王超 on 13-10-29.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "Change.h"

@implementation Change

@synthesize shareText;
@synthesize shareImage;
@synthesize height;
@synthesize userImage;
@synthesize name;

- (BOOL)hasImage
{
    return self.shareImage == nil ? NO:YES;
}
- (CGFloat)heightForFont:(UIFont *)font WithWidth:(CGFloat)width
{
    CGFloat textHeight = 0.0f;
    CGFloat imageHeight = 0.0f;
    NSString *text = self.shareText;
    CGSize max = CGSizeMake(width, 1000.0f);
    CGSize labelsize = [text sizeWithFont:font constrainedToSize:max lineBreakMode:UILineBreakModeCharacterWrap];
    textHeight = labelsize.height;
    if ([self hasImage]) {
        imageHeight = 70.0f;
        return textHeight + imageHeight + 75;
    }
    return textHeight + imageHeight + 110;
}




@end
