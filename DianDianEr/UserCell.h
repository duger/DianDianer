//
//  UserCell.h
//  DianDianEr
//
//  Created by 王超 on 13-11-13.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCMusicEngine.h"
#import "Mp3PlayerButton.h"

@interface UserCell : UITableViewCell
//用户名字
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
//分享的时间
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
//分享的位置
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
//分享的文字内容
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;
//分享的照片
@property (strong, nonatomic) IBOutlet UIImageView *shareImage;
//评论的按钮
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
//被评论的数量
@property (strong, nonatomic) IBOutlet UILabel *commentCount;
//赞的按钮
@property (strong, nonatomic) IBOutlet UIButton *goodButton;
//被赞的数量
@property (strong, nonatomic) IBOutlet UILabel *goodCount;
@property (strong, nonatomic) Mp3PlayerButton *playButton;
//按钮下的view
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property(assign,nonatomic) BOOL isGoodorNot;

@end
