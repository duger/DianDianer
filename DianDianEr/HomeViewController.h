//
//  HomeViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

- (IBAction)didClickBack:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationbar;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (nonatomic,retain) NSMutableArray *shareArray;
@property (nonatomic,retain) UITableView *tableView;

@end
