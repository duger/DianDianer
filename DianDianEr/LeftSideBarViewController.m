//
//  LeftSideBarViewController.m
//  SideBar
//
//  Created by 王超 on 13-10-17.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "LeftSideBarViewController.h"
#import "FirstViewController.h"
#import "SidebarViewController.h"
#import "HomeViewController.h"
#import "PrivacyViewController.h"
#import "FirstViewController.h"
#import "LoginViewController.h"
#import "SystemViewController.h"
#import "FriendCell.h"


@interface LeftSideBarViewController ()
{
    int _selectIdnex;
}
@end

@implementation LeftSideBarViewController
{
    NSMutableArray *selectArray;
    NSMutableArray *backImageList;
}

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBackground320*568.png"]];
    self.tableView_1.backgroundColor = [UIColor clearColor];
//    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"图层-3-副本@2x.png"]];
    backImageList = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"personal.png"],[UIImage imageNamed:@"setting.png"],[UIImage imageNamed:@"logout.png"],nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [ self.tableView_1 registerClass:[UserCell class] forCellReuseIdentifier:@"selectCell"];
//    [self.tableView_1 registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"selectCell"];
//    selectArray = [[NSMutableArray alloc] initWithObjects: @"个人主页",@"设置",@"注销",nil];
    self.tableView_1.dataSource = self;
    self.tableView_1.delegate = self;
    
    if ([delegate respondsToSelector:@selector(leftSideBarSelectWithController:)]) {
        [delegate leftSideBarSelectWithController:[self subConWithIndex:0]];
        _selectIdnex = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self presentViewController:homeVC animated:YES completion:^{
            nil;
        }];
    }
//    else if (indexPath.row == 1){
//        PrivacyViewController *privacyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
//        [self presentViewController:privacyVC animated:YES completion:^{
//            nil;
//        }];
//    }
    else if (indexPath.row == 1){
        SystemViewController *systemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SystemViewController"];
        [self presentViewController:systemVC animated:YES completion:^{
            nil;
        }];
    }
    else if (indexPath.row == 2){
        //注销用户
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kLoginOrNot];
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
        //注销
        [[XMPPManager instence] loginOut];

        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

#pragma mark - UITableView DateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.imageView.image = backImageList[indexPath.row];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(130, 10, 80, 30)];
    [cell addSubview:label];
    label.text = [selectArray objectAtIndex:indexPath.row];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    label.textColor = [UIColor whiteColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 55.0f;
}

- (UINavigationController *)subConWithIndex:(int)index
{
    FirstViewController *con = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    con.index = index+1;
    UINavigationController *nav= [[UINavigationController alloc] initWithRootViewController:con];
    nav.navigationBar.hidden = NO;
    return nav;
}

- (void)viewDidUnload
{
    [self setTableView_1:nil];
    [super viewDidUnload];
}

@end
