//
//  BrithdaySlect.m
//  DianDianEr
//
//  Created by 信徒 on 13-11-4.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "BrithdaySlect.h"

@implementation BrithdaySlect
@synthesize delegate;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)selectDate:(UIButton *)sender
{
    [self.delegate selectBrithday:sender];
}
@end
