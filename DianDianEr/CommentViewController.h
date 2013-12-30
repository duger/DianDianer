//
//  CommentViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-11-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Share.h"
#import "NCMusicEngine.h"
#import "MMProgressHUD.h"

@interface CommentViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,NCMusicEngineDelegate>

//输入的toolBar
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
//navigation
@property (strong, nonatomic) IBOutlet UIView *topView;
//返回按钮
@property (strong, nonatomic) IBOutlet UIButton *backButton;
//点击返回按钮
- (IBAction)didClickBack:(UIButton *)sender;
//发送按钮
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
//输入框
@property (strong, nonatomic) IBOutlet UITextField *content;
//点击发送按钮
- (IBAction)didClickSend:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *aTableView;

@property (retain,nonatomic) Share *shareFromFirstView;            //来自首页的一条分享

@end
