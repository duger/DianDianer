//
//  RightSideBarViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKTabBarController.h"
#import "FriendsViewController.h"

@interface RightSideBarViewController : AKTabBarController<FriendsViewControllerDelegate>
@property (nonatomic, strong) AKTabBarController *tabBarController;
@end
