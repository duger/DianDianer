//
//  MessageCell.h
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
//头像
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//最后一条消息内容
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
