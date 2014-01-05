//
//  FriendCell.m
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}



-(void)awakeFromNib
{
    [super awakeFromNib];
    self.headImage.layer.cornerRadius = 10;
    self.headImage.layer.masksToBounds = YES;
    self.unReadMessageCount.layer.cornerRadius = 9;
    self.unReadMessageCount.layer.masksToBounds = YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//设置未读消息数量
- (void)setUnReadMessage:(NSNumber *)count
{
    self.unReadMessageCount.hidden = YES;
    if (count.integerValue > 0) {
        self.unReadMessageCount.text = [count stringValue];
        self.unReadMessageCount.hidden = NO;
    }
    
}


@end
