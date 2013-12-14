//
//  PopInfoCell.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "PopInfoCell.h"

@implementation PopInfoCell
@synthesize delegate;

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

- (IBAction)btn1:(id)sender
{
    [delegate bt1];
}

- (IBAction)btn2:(id)sender
{
    [delegate bt2];
}
@end
