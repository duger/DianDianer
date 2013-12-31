//
//  RegisterViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"



@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize userName;
@synthesize userPassword;
@synthesize userPassword2;
@synthesize backButtonOne;
@synthesize backButtonTwo;
@synthesize nextStepButton;
@synthesize resignButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    //先连接 再注册
    [XMPPManager instence].delegate = self;
    
    
    if (IS_IPHONE5) {
       
    }else{
            }


    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"resign.png"]];
    [self.view setFrame:CGRectMake(0, 0, 320, 1200)];
    
//    [[NSNotificationCenter defaultCenter] addObserver:userName selector:@selector(goToSetPassWord:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [userName setCenter:CGPointMake(178, 278)];
    [nextStepButton setCenter:CGPointMake(160, 340)];
    [backButtonOne setCenter:CGPointMake(160, 440)];
    
    [userPassword setCenter:CGPointMake(178, 728)];
    [userPassword2 setCenter:CGPointMake(178, 783)];
    [resignButton setCenter:CGPointMake(160, 840)];
    [backButtonTwo setCenter:CGPointMake(160, 940)];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:userPassword action:@selector(resignFirstResponder)];
    [tapGes addTarget:userPassword2 action:@selector(resignFirstResponder)];
    [tapGes addTarget:userName action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tapGes];
    userPassword.delegate = self;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
  
#pragma UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//
//    [UIView animateWithDuration:1.0 animations:^{
//        [self.view setFrame:CGRectMake(0, -500, 320, 1000)];
//    } completion:^(BOOL finished) {
//        [userPassword becomeFirstResponder];
//    }];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([userName resignFirstResponder]||
        [userPassword resignFirstResponder]||
        [userPassword2 resignFirstResponder]){
        return YES;
    }
    return NO;
}
- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserPassword:nil];
    [self setUserPassword2:nil];

    [self setIsUserName:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}

#pragma mark private methods
- (IBAction)didClickButtonOne:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didClickButtonTwo:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didClickNextStepButton:(UIButton *)sender {
    [userName resignFirstResponder];
    [UIView animateWithDuration:0.4 animations:^{
        [self.view setFrame:CGRectMake(0, -500, 320, 1400)];
    } completion:^(BOOL finished) {
//        [userPassword becomeFirstResponder];
    }];
}

- (IBAction)didClickResignButton:(UIButton *)sender {
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    _isUserName.hidden = YES;
    
    //所有的register对象
    
    
    NSMutableArray * userInfo = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in array) {
        NSString *tempName = [dic objectForKey:@"Account"];
        if ( [dic objectForKey:@"Account"]) {
            [userInfo addObject:tempName];
        }
    }
    
    if (userName.text.length < 5) {
        NSLog(@"昵称必须大于6位");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                            message:@"昵称必须大于6位！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if([userInfo containsObject:userName.text] )
    {
        _isUserName.hidden = NO;
        NSLog(@"账号已经被占用");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                            message:@"账号已经被占用！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    if(userPassword.text.length < 4)
    {
        NSLog(@"密码必须大于6位");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                            message:@"密码必须大于6位！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if(![userPassword.text isEqualToString: userPassword2.text])
    {
        
        NSLog(@"两次密码不一样");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败"
                                                            message:@"两次密码不一样！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    if (userName.text.length >= 5 && [userPassword.text isEqualToString: userPassword2.text] && userPassword.text.length >= 4)
    {
        
        
        [[XMPPManager instence]registerInSide:userName.text andPassword:userPassword.text];
        return;
    }
    else
    {
        NSLog(@"注册失败");
    }

}

- (IBAction)goUpView:(UIButton *)sender {
    [UIView animateWithDuration:0.4 animations:^{
        [self.view setFrame:CGRectMake(0, 0, 320, 1400)];
    } completion:^(BOOL finished) {

    }];

    
    
}



-(void)leaveRegister
{
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
