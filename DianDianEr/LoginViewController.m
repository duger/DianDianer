//
//  LoginViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "LoginViewController.h"


#import "SidebarViewController.h"
#import "RegisterViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"



@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userName;
@synthesize userPassword;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

        
        [self.topView setFrame: CGRectMake(0, 203, 320, 330)];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone5-background.png"]]];
        
        if (!IS_IPHONE5SCREEN) {
            
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone4-background.png"]];
            [self.topView setFrame: CGRectMake(0, 170, 320, 330)];
        }

    [XMPPManager instence].delegate = self;
    
    
    
    
    
    /*
     if (![[XMPPManager instence]connect]) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
     message:@"See console for error details."
     delegate:nil
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil];
     [alertView show];
     }
     
     */
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]) {
        self.userName.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword]) {
        self.userPassword.text = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword];
    }
    

    //密码不显示
    self.userPassword.secureTextEntry = YES;
    //点击屏幕去键盘
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:userPassword action:@selector(resignFirstResponder)];
    [tapGes addTarget:userName action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tapGes];
    
    
    self.userName.text = @"";
    self.userPassword.text = @"";
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    
    //加个观察者去 使界面移动
    //键盘弹出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘收回
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewDidUnload {
    [self setUserName:nil];
    [self setUserPassword:nil];
    [super viewDidUnload];
}
- (IBAction)didClickRegister:(UIButton *)sender {
    RegisterViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)testLogin:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [[NSUserDefaults standardUserDefaults] setObject:kGUEST forKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] setObject:kGUESTPASSWORD forKey:kXMPPmyPassword];
    [[XMPPManager instence]connect];
    
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    
    [self.navigationController pushViewController:sidebarVC animated:YES];
}

- (IBAction)didClickLogin:(UIButton *)sender
{

    
//    [MMProgressHUD showWithTitle:@"登陆" status:@"请稍等..."];
    [MMProgressHUD showWithTitle:@"登陆" status:@"连接中..." cancelBlock:^{
        [[XMPPManager instence].xmppStream disconnect];
    }];
       
    if ( [self.userName.text isEqualToString:@""]||[self.userPassword.text isEqualToString:@""])
    {
        
        [MMProgressHUD dismissWithError:@"请输入用户名或者密码!" title:@"登陆失败"];
        NSLog(@"登陆失败");
    
    }else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
        [[NSUserDefaults standardUserDefaults] setObject:self.userName.text forKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] setObject:self.userPassword.text forKey:kXMPPmyPassword];
        [[XMPPManager instence]connect];
//        if ([[XMPPManager instence].xmppStream isDisconnected]) {
//            [MMProgressHUD dismissWithError:@"网络错误"];
//        }else
        [self performSelector:@selector(isConectedOrNot:) withObject:nil afterDelay:5.0f];
    }

    
}

-(void)isConectedOrNot:(id)sender
{
    if ([[XMPPManager instence].xmppStream isDisconnected]) {
        [MMProgressHUD dismissWithError:@"请检查网络!" title:@"登陆超时" afterDelay:1.0f];
    }
    
}
#pragma mark - Keyboard Notification Mothods
-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    [self autoMoveKeyboard:keyboardHeight andAnimationDuration:animationDuration];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [self autoMoveKeyboard:160 andAnimationDuration:0];
}


-(void)autoMoveKeyboard:(CGFloat)keyBoardHeight andAnimationDuration:(NSTimeInterval)animationDuration
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 160 - keyBoardHeight, self.view.bounds.size.width, self.view.bounds.size.height);
    }];

    
    
    
}


#pragma mark - xmppmanager Delegate
-(void)authenticateSuccessed
{
    [MMProgressHUD dismissWithSuccess:@"Enjoy!"];
    
    
    SidebarViewController *sidebarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SidebarViewController"];
    [self.navigationController pushViewController:sidebarVC animated:YES];
    
}
-(void)authenticateFailed
{
    [MMProgressHUD dismissWithError:@"用户名或者密码错误!"title:@"登陆失败"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [[XMPPManager instence]disconnect];
    
}

#pragma UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([userName resignFirstResponder]||
        [userPassword resignFirstResponder]) {
        return YES;
    }
    return NO;
}

@end
