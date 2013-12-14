//
//  HomePageCell.h
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCMusicEngine.h"
#import "Mp3PlayerButton.h"


@interface HomePageCell : UITableViewCell
//@property (nonatomic,retain) Mp3PlayerButton *playButton;
//头像
@property (weak, nonatomic) IBOutlet UIImageView *headName;
//昵称
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//分享时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//分享的位置
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
//分享的文字内容
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
//分享的照片
@property (weak, nonatomic) IBOutlet UIImageView *shareImage;
//评论的按钮
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
//被评论的数量
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
//赞的按钮
@property (strong, nonatomic) IBOutlet UIButton *goodButton;
//被赞过的数量
@property (weak, nonatomic) IBOutlet UILabel *praiseCount;
//图标下的view
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) Mp3PlayerButton *playButton;
@property (retain, nonatomic) NSString * shareID;
@property(assign,nonatomic) BOOL isGoodorNot;
@property(retain,nonatomic) Share *currentShare;
- (IBAction)didClickGood:(UIButton *)sender;
-(CGRect)thegetShareLabelSize:(Share *)share;
@end
