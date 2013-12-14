//
//  PrivacyViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTypeCell.h"
#import "BrithdaySlect.h"
@interface PrivacyViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomTypeCellDelegate,UITextFieldDelegate,BrithdaySlectDelegate,UIAlertViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

- (IBAction)didClickBack:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIView *topView;



@end
