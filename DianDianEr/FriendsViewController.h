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

@interface FriendsViewController : UIViewController<UITextFieldDelegate,NSFetchedResultsControllerDelegate,XMPPManagerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property(retain,nonatomic) NSMutableArray *friendsList;


- (IBAction)didClikAddFriendsButton:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UILabel *friendLabel;


@property(nonatomic,assign) id<FriendsViewControllerDelegate> delegate;

//xmppRoser结果
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@end
