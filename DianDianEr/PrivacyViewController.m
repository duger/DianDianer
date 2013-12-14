//
//  PrivacyViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "PrivacyViewController.h"
#import "LeftSideBarViewController.h"
#import "CustomTypeCell.h"
#import "BrithdaySlect.h"

@interface PrivacyViewController ()
{
    UITableView     *aTableView;
    float keyboardHeight;
    
    BrithdaySlect * brithdaySlect;
    UITableView     *yearTableView;
    UITableView     *monthTableView;
    UITableView     *dayTableView;
    UIView          *viewBackground;
    
    UIAlertView    *alertPassword;
    UIAlertView    *alertTelephone;
    UITextField     *telePhoneField;
    UITextField     *passwordField;
    
    UIImage         *userImage;
}

@end

@implementation PrivacyViewController
@synthesize topView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
    }
    
    aTableView = [[UITableView alloc] initWithFrame:CGRectMake(topView.frame.origin.x, topView.frame.origin.y+topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60)
                                              style:UITableViewStyleGrouped];
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didClickBack:(UIBarButtonItem *)sender
{

    [self dismissViewControllerAnimated:YES completion:nil];
    //    [self.navigationController popViewControllerAnimated:YES];

}
- (void)viewDidUnload {
    [self setTopView:nil];
    //移除监听键盘的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark TableView Datesource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (aTableView == tableView)
    {
        switch (section) {
            case 0:
                return 2;
                break;
            case 1:
                return 7;
                break;
            default:
                break;
        }
        return 0;
    }
    else if (yearTableView == tableView)
    {
        return 113;
    } else if (monthTableView == tableView)
    {
        return 12;
    }else
        return 31;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (aTableView == tableView) {
//        static NSString *cellIdentifier_section_0 = @"cellIdentifier_section_0";
        static NSString *cellIdentifier_section_1 = @"cellIdentifier_section_1";
        static NSString *cellIdentifier_section_2 = @"cellIdentifier_section_2";
//        static NSString *cellIdentifier_section_3 = @"cellIdentifier_section_3";
        
        CustomTypeCell * cell = nil;
        switch (indexPath.section) {
//            case 0:
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_0];
//                if (cell == nil) {
//                    cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_0 cellType:CelldefaultType];
//                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                }
//                cell.textLabel.text = @"只有朋友可以找到我";
//                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                [cell     refresh];
//                [cell     setDelegate:self];
//            }
//                break;
            case 0:
            {
                if (indexPath.row == 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_1];
                    if (cell == nil) {
                        cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_1 cellType:CellBigImageType];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.userImageView.image = [UIImage imageNamed:@"Retina-Home-Screen---114px"];
                    cell.userImageView.image = userImage;
//                    cell.qianmingLablel.text = [NSString stringWithFormat:@"个性签名接受数据口"];
//                    cell.qianmingLablel.delegate = self;
//                    cell.qianmingLablel.keyboardType = UIKeyboardAppearanceDefault;
//                    cell.qianmingLablel.returnKeyType = UIReturnKeyDone;
                    
                    
                    [cell  setDelegate:self];
                }
                
                else if(indexPath.row < 2)
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_2];
                    if (cell == nil) {
                        cell = (CustomTypeCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_2];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
//                    NSArray * array = @[@"更改密码",@"电话号码",@"生日"];
//                    cell.textLabel.text = [array objectAtIndex:indexPath.row - 1];
//                    cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16];
//                    cell.textLabel.textColor = [UIColor blueColor];
//                    cell.textLabel.textAlignment = 1;
                    cell.textLabel.text = @"更改密码";
                    cell.textLabel.textAlignment = 1;
                    
                }
//                else
//                {
//                    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_3];
//                    if (cell == nil) {
//                        cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_3 cellType:CellTextFieldType];
//                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                    }
//                    NSArray * array = @[@"QQ、MSN",@"name",@"FirstName"];
//                    cell.textfield.tag = indexPath.row + 1000;
//                    cell.textfield.placeholder = [array objectAtIndex:indexPath.row -4];
//                    cell.textfield.font = [UIFont fontWithName:@"Optima" size:16];
//                    cell.textfield.delegate = self;
//                    [cell setDelegate:self];
//                }
            }
                break;
        }
        return cell;
    }
    else if (yearTableView == tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%d", 1900+indexPath.row];
        
        // Configure the cell...
        
        return cell;
    }
    else if (yearTableView == tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%d", 1900+indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:10.0];
        
        // Configure the cell...
        
        return cell;
    }
    else if (monthTableView == tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%d", 1+indexPath.row];
        cell.textLabel.textAlignment = 2;
        
        // Configure the cell...
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%d", 1+indexPath.row];
        cell.textLabel.textAlignment = 2;
        
        // Configure the cell...
        
        return cell;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (aTableView == tableView)
    {
        return 1;
    }
    
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (aTableView == tableView)
    {
        NSArray * array = @[@"隐私政策",@"我"];
        NSString * title = [array objectAtIndex:section];
        return title;
    }else
        return nil;
}
#pragma UITextView代理
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    NSLog(@"个性签名是%@",textView.text);
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text] == YES)
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (aTableView == tableView)
    {
        if (indexPath.row ==0 && indexPath.section == 0) {
            return 70.0f;
        }
        return 40;
    }
    else
        return 20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (aTableView == tableView)
    {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 1:
                {
                    alertPassword = [[UIAlertView alloc] initWithTitle:@"更改密码" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    
                    passwordField = [[UITextField alloc] initWithFrame:CGRectMake(14, 35, 256, 20)];
                    passwordField.secureTextEntry = YES;
                    passwordField.placeholder = @"password";
                    passwordField.backgroundColor = [UIColor whiteColor];
                    [alertPassword addSubview:passwordField];
                    alertPassword.frame = CGRectMake(0, 0, 320, 200);
                    [alertPassword show];
                    
                    alertPassword.delegate = self;
                }
                    break;
                case 2:
                {
                    alertTelephone = [[UIAlertView alloc] initWithTitle:@"电话号码" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    
                    telePhoneField = [[UITextField alloc] initWithFrame:CGRectMake(14, 35, 256, 20)];
                    telePhoneField.secureTextEntry = YES;
                    telePhoneField.placeholder = @"telePhone";
                    telePhoneField.keyboardType =  UIKeyboardTypeNumberPad;
                    telePhoneField.backgroundColor = [UIColor whiteColor];
                    [alertTelephone addSubview:telePhoneField];
                    alertTelephone.frame = CGRectMake(0, 0, 320, 200);
                    [alertTelephone show];
                    
                    alertTelephone.delegate = self;
                }
                    break;
                case 3:
                {
                    NSLog(@"生日");
                    viewBackground.hidden = NO ;
                    viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWIDTH_SCREEN, kHEIGHT_SCREEN)];
                    [self.view addSubview:viewBackground];
                    viewBackground.backgroundColor = [UIColor grayColor];
                    viewBackground.alpha = 0.7;
                    
                    brithdaySlect = [[[NSBundle mainBundle] loadNibNamed:@"BrithdaySelect" owner:nil options:nil] objectAtIndex:0];
                    brithdaySlect.frame = CGRectMake(55, 150, 210, 220);
                    brithdaySlect.delegate = self;
                    brithdaySlect.backgroundColor = [UIColor clearColor];
                    brithdaySlect.alpha = 0.7;
                    
                    [viewBackground addSubview:brithdaySlect];
                    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(265, 150, 30, 20)];
                    [btn setTitle:@"OK" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectOk) forControlEvents:UIControlEventTouchUpInside];
                    [viewBackground addSubview:btn];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (yearTableView == tableView)
    {
        brithdaySlect.yearLabel.text = [NSString stringWithFormat:@"%d",indexPath.row +1900];
        
    }
    if (monthTableView == tableView)
    {
        brithdaySlect.monthLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
        
    }
    if (dayTableView == tableView)
    {
        brithdaySlect.dayLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
        
    }
    
}

#pragma 生日
-(void)selectBrithday:(UIButton *)btn
{
    if ([btn.titleLabel.text isEqualToString:@"年"])
    {
        yearTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 23, 70, 200) style:UITableViewStylePlain];
        yearTableView.dataSource = self;
        yearTableView.delegate = self;
        [brithdaySlect addSubview:yearTableView];
    }
    else if ([btn.titleLabel.text isEqualToString:@"月"])
    {
        monthTableView = [[UITableView alloc] initWithFrame:CGRectMake(80, 23, 50, 200) style:UITableViewStylePlain];
        monthTableView.dataSource = self;
        monthTableView.delegate = self;
        [brithdaySlect addSubview:monthTableView];
    }
    else
    {
        if (dayTableView) {
            return ;
        }
        dayTableView = [[UITableView alloc] initWithFrame:CGRectMake(150, 23, 50, 200) style:UITableViewStylePlain];
        dayTableView.dataSource = self;
        dayTableView.delegate = self;
        [brithdaySlect addSubview:dayTableView];
    }
}

- (void)selectOk
{
    NSString * string = [NSString stringWithFormat:@"%@ %@ %@",brithdaySlect.yearLabel.text,brithdaySlect.monthLabel.text,brithdaySlect.dayLabel.text];
    NSLog(@"%@",string);
    [viewBackground removeFromSuperview];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"代理按钮方法");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (alertPassword == alertView)
    {
        switch (buttonIndex) {
            case 0:
                return;
                break;
            case 1:
                NSLog(@"更改后的密码是%@",passwordField.text);
                break;
            default:
                break;
        }
    }
    if (alertTelephone == alertView)
    {
        switch (buttonIndex) {
            case 0:
                return;
                break;
            case 1:
                NSLog(@"电话号码是%@",telePhoneField.text);
                break;
                
            default:
                break;
        }
    }
    
}
- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if ([NSNotificationCenter defaultCenter]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma CustomTypeCellDelegate方法
-(void)asdiohfvsalkjvhdsalkjfvbhasdjk:(CustomTypeCell *)sender
{
    NSLog(@"只有朋友可以找到我");
    [sender refresh];
}
-(void)buttonSetTouXiang:(CustomTypeCell *)sender
{
    NSLog(@"设置头像");
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    //或者UIImagePickerControllerSourceTypePhotoLibrary
    ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    ipc.delegate = self;
//    ipc.allowsImageEditing = YES; // allowsEditing in 3.1
    ipc.allowsEditing = YES;
    [self presentModalViewController:ipc animated:YES];
    
}
-(void)buttonSetFengMian:(CustomTypeCell *)sender
{
    NSLog(@"设置封面");
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    NSLog(@"1111picker    %@",picker);
//    NSLog(@"image    %@",image);
//    NSLog(@"editingInfo    %@",editingInfo);
//    NSMutableDictionary * dict= [NSMutableDictionary dictionaryWithDictionary:editingInfo];
//    
//    [dict setObject:info forKey:@"UIImagePickerControllerEditedImage"];
//    
//    //直接调用3.x的处理函数
//    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
//}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    userImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [aTableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"3333%@",picker);
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight =keyboardRect.size.height;
    
    CATransition *animation = [CATransition animation];
    animation.duration = animationDuration;
    animation.delegate = self;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    
    [[aTableView layer] addAnimation:animation forKey:nil];
    
    aTableView.frame = CGRectMake(topView.frame.origin.x, topView.frame.origin.y+topView.frame.size.height -keyboardHeight - 20 ,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    aTableView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 44, kWIDTH_SCREEN, kHEIGHT_SCREEN - 60);
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITextField * tf = textField;
    switch (tf.tag) {
        case 1004:
            NSLog(@"QQ,MSN%@",tf.text);
            break;
        case 1005:
            NSLog(@"name%@",tf.text);
            break;
        case 1006:
            NSLog(@"FirstName%@",tf.text);
            break;
            
        default:
            break;
    }
    return YES;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField resignFirstResponder]) {
        return YES;
    }
    return NO;
}
@end
