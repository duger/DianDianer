//
//  FriendCell.h
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//个性签名
@property (weak, nonatomic) IBOutlet UILabel *ideaLabel;
//聊天的图标
@property (weak, nonatomic) IBOutlet UIImageView *chatImage;
//未读消息数量
@property (strong, nonatomic) IBOutlet UILabel *unReadMessageCount;

//设置未读消息数量
- (void)setUnReadMessage:(NSNumber *)count;
@end
