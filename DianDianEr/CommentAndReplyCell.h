//
//  CommentAndReplyCell.h
//  DianDianEr
//
//  Created by 王超 on 13-11-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAndReplyCell : UITableViewCell
//评论者image
@property (strong, nonatomic) IBOutlet UIImageView *commentImage;
//评论者的名字
@property (strong, nonatomic) IBOutlet UILabel *commentUserName;
//评论的事件
@property (strong, nonatomic) IBOutlet UILabel *commentDate;
//评论的内容
@property (strong, nonatomic) IBOutlet UILabel *commentContent;
//回复按钮
@property (strong, nonatomic) IBOutlet UIButton *replyButton;
//用来接受commentID
@property(nonatomic,copy) NSString *commentID;

@end
