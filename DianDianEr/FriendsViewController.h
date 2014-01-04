//
//  FriendsViewController.h
//  DianDianEr
//
//  Created by Duger on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FriendsViewControllerDelegate <NSObject>
-(void)goToChartroom;
@end

@interface FriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;


- (IBAction)didClikAddFriendsButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UILabel *friendLabel;


@property(nonatomic,assign) id<FriendsViewControllerDelegate> delegate;

//xmppRoser结果
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end
