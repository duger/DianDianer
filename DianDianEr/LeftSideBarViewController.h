//
//  LeftSideBarViewController.h
//  SideBar
//
//  Created by 王超 on 13-10-17.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SideBarSelectDelegate;
@interface LeftSideBarViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView_1;
@property (assign,nonatomic)id<SideBarSelectDelegate>delegate;



@end
