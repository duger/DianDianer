//
//  FirstViewController.h
//  side2
//
//  Created by 王超 on 13-10-17.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomItem.h"
#import "AwesomeMenu.h"

#import "CameraViewController.h"
#import "TuYaViewController.h"
#import "MJRefresh.h"
#import "RecordViewController.h"
#import "NCMusicEngine.h"


@interface FirstViewController : UIViewController<AwesomeMenuDelegate,CameraViewControllerDelegate,TuYaViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,RecordViewControllerDelegate,UIActionSheetDelegate,NCMusicEngineDelegate>
@property (nonatomic,retain) NSMutableArray *shareArray;
- (IBAction)cicCLickZuoBian:(CustomItem *)sender;
- (IBAction)didClickRight:(CustomItem *)sender;
- (IBAction)showMenu:(UIButton *)sender;
@property (assign, nonatomic) IBOutlet UINavigationBar *customVaviBar;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *containView;

@property (assign,nonatomic) int index;
@end
