//
//  CustomMapCell.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "CustomMapCell.h"


@implementation CustomMapCell
@synthesize delegate;
@synthesize chageTitle;
@synthesize changeSubtitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}


- (IBAction)bt1:(UIButton *)sender
{

    [delegate buttonChange1:sender];
}

- (IBAction)bt2:(UIButton *)sender
{
    [delegate buttonChange2:sender];
}


@end
