//
//  ChartViewController.h
//  XMPP
//
//  Created by Duger on 13-10-22.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "MJRefresh.h"

@interface ChartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MJRefreshBaseViewDelegate,XMPPManagerMessageDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UITextField *enterTextField;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *toSomeOneLabel;

//@property (nonatomic, retain) IBOutlet FaceViewController   *phraseViewController;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;

@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic,retain) XMPPJID *toSomeOne;


//头像
@property (nonatomic, strong) UIImage *selfHeadImage;
@property (nonatomic, strong) UIImage *friendHeadImage;

//发送消息
- (IBAction)didClickSendButton:(UIBarButtonItem *)sender;

- (IBAction)didClickBack:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *topView;
//消息列表
@property (strong, nonatomic) NSFetchedResultsController *fetchedMessageResultsController;

@end
