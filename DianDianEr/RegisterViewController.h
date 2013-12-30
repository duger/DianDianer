//
//  RegisterViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<XMPPManagerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPassword;
@property (strong, nonatomic) IBOutlet UITextField *userPassword2;

@property (strong, nonatomic) IBOutlet UILabel *isUserName;
@property (strong, nonatomic) IBOutlet UIButton *backButtonOne;
@property (strong, nonatomic) IBOutlet UIButton *backButtonTwo;
@property (strong, nonatomic) IBOutlet UIButton *nextStepButton;
@property (strong, nonatomic) IBOutlet UIButton *resignButton;



- (IBAction)didClickButtonOne:(UIButton *)sender;

- (IBAction)didClickButtonTwo:(UIButton *)sender;
- (IBAction)didClickNextStepButton:(UIButton *)sender;


- (IBAction)didClickResignButton:(UIButton *)sender;
//返回用户名界面
- (IBAction)goUpView:(UIButton *)sender;


@end
