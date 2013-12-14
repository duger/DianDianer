//
//  CheckCell.m
//  DianDianEr
//
//  Created by 王超 on 13-11-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "CheckCell.h"

@implementation CheckCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.playButton = [[Mp3PlayerButton alloc]initWithFrame:CGRectMake(self.shareSound.bounds.origin.x, self.shareSound.bounds.origin.y, 30, 30)];
    [self.shareSound addSubview:self.playButton];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.shareSound.frame = CGRectMake(10, self.bounds.size.height - 40, 30, 30);
    self.commentButton.frame =CGRectMake(280, self.bounds.size.height - 40, 30, 30);
    self.shareImage1.frame = CGRectMake(10, self.bounds.size.height-403, 300,353);
    self.headImage.frame = CGRectMake(10, 10, 45, 45);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
