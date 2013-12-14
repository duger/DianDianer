//
//  CheckCell.h
//  DianDianEr
//
//  Created by 王超 on 13-11-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mp3PlayerButton.h"

@interface CheckCell : UITableViewCell
//分享者的头像
@property (strong, nonatomic) IBOutlet UIImageView *headImage;
//分享者的昵称
@property (strong, nonatomic) IBOutlet UILabel *userName;
//分享的时间
@property (strong, nonatomic) IBOutlet UILabel *shareTime;
//分享的地址
@property (strong, nonatomic) IBOutlet UILabel *shareAddress;
//分享的内容
@property (strong, nonatomic) IBOutlet UILabel *shareContent;
//分享的图片
@property (strong, nonatomic) IBOutlet UIImageView *shareImage1;
//分享的语音
@property (strong, nonatomic) IBOutlet UIView *shareSound;

@property (strong, nonatomic) Mp3PlayerButton *playButton;
//评论按钮
@property (strong, nonatomic) IBOutlet UIButton *commentButton;

@end
