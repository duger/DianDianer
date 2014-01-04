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

@interface ChartViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,XMPPRosterDelegate,MJRefreshBaseViewDelegate,XMPPManagerDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UITextField *enterTextField;
- (IBAction)didClickButton:(UIBarButtonItem *)sender;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

//@property (nonatomic, retain) IBOutlet FaceViewController   *phraseViewController;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) NSMutableArray		 *chatArray;

@property (nonatomic, retain) NSDate                 *lastTime;
@property (nonatomic,retain) NSString *toSomeOne;  
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;    //单例获得
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;

- (IBAction)didClickBack:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *topView;
//消息列表
@property (strong, nonatomic) NSFetchedResultsController *fetchedMessageResultsController;

@end
