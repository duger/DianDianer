//
//  SystemViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTypeCell.h"
#import "FTCoreTextView.h"

@interface SystemViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomTypeCellDelegate,FTCoreTextViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *topView;

- (IBAction)didClickBack:(UIBarButtonItem *)sender;


@end
