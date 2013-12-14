//
//  ShareViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareManager.h"
#import "CameraViewController.h"
#import "SelectManager.h"
#import "MapViewController.h"
#import "TuYaViewController.h"
#import "Singleton.h"
#import "RecordViewController.h"
#import "Mp3PlayerButton.h"
#import "NCMusicEngine.h"


@interface ShareViewController ()
@end

@implementation ShareViewController
{
    NCMusicEngine *_player;
    UIButton *player1;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.shareImage = [[UIImageView alloc]init];
    TuYaViewController *tuyaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TuYaViewController"];
    tuyaVC.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.shareContent becomeFirstResponder];
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
        self.shareImage.center = CGPointMake(45, 140);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
        self.shareImage.center = CGPointMake(45, 100);
    }
    self.shareImage.image = [UIImage imageWithContentsOfFile:[ShareManager defaultManager].tempImagePath];
    self.lacationTextField.text = [ShareManager defaultManager].locationPlace;
    if (self.shareImage.image == nil) {
        self.shareImage.hidden = YES;
        self.shareContent.frame = CGRectMake(12, 90, 295, 90);
    }
    else{
        self.shareImage.hidden = NO;
        
        self.shareContent.frame = CGRectMake(83, 90, 240, 90);
    }
    player1 = [[UIButton alloc]initWithFrame:CGRectMake(self.teamView.bounds.origin.x+259, self.teamView.bounds.origin.y+11, 25, 25)];
    [player1 setBackgroundImage: [UIImage imageNamed:@"按钮-播放.png"] forState:UIControlStateNormal];
//    player1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"按钮-播放.png"]];
    [self.teamView addSubview:player1];
    NSLog(@"%@",[ShareManager defaultManager].inPutSoundsPath);
    if ([[ShareManager defaultManager].inPutSoundsPath isEqualToString:@""]) {
        
        player1.hidden = YES;
    }
    else
    {
        player1.hidden = NO;
        [player1 addTarget:self action:@selector(playSounds:) forControlEvents:UIControlEventTouchDown];
    }
    
    [self.shareContent becomeFirstResponder];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.shareContent.layer.borderColor = [UIColor grayColor].CGColor;
    
//    self.shareContent.layer.borderWidth =1.0;
//    self.shareContent.layer.cornerRadius =10.0;
    
    [self.uploadProgress setProgress:0.0f animated:YES];
    [ShareManager defaultManager].delegate = self;
    [CameraViewController instence].delegate = self;
//    [self.shareContent becomeFirstResponder];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
//    NSString *lacation = [NSString stringWithFormat:@"坐标：E%f,N%f",[ShareManager defaultManager].longitude,[ShareManager defaultManager].latitude];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    self.uploadProgress.hidden = YES;
    
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight =keyboardRect.size.height;
    
    CATransition *animation = [CATransition animation];
	animation.duration = animationDuration;
	animation.delegate = self;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
    
	[[self.teamView layer] addAnimation:animation forKey:nil];
    
    self.teamView.frame = CGRectMake(0 ,self.view.bounds.size.height - keyboardHeight - self.teamView.bounds.size.height ,320,self.teamView.bounds.size.height);
    
}
-(void)keyboardHidden:(NSNotification *)notification
{
    self.teamView.frame = CGRectMake(0, 414, 320, self.teamView.bounds.size.height);
}

-(void)playSounds:(id) sender
{
    if (self.avPlay.playing) {
        [self.avPlay stop];
        [player1 setBackgroundImage: [UIImage imageNamed:@"按钮-播放.png"] forState:UIControlStateNormal];
        return;
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[RecordViewController defaultManager].urlPlay error:nil];
    NSLog(@"%@",[RecordViewController defaultManager].urlPlay);
    self.avPlay = player;
    [self.avPlay play];
    [player1 setBackgroundImage: [UIImage imageNamed:@"按钮-暂停.png"] forState:UIControlStateNormal];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [ShareManager defaultManager].tempImagePath = @"";
    self.shareContent.text = @"";
    [ShareManager defaultManager].locationPlace = @"";
    [ShareManager defaultManager].inPutSoundsPath = @"";
}

- (IBAction)didClickImageUploadTest:(UIButton *)sender
{
    [[ShareManager defaultManager] uploadWithCompletionBlock:NULL];
}

-(void)changeUploadProgress:(CGFloat)progress
{
    [self.uploadProgress setProgress:progress animated:YES];
}

- (void)viewDidUnload {
    [self setUploadProgress:nil];
    [self setShareContent:nil];
    [self setShareImage:nil];
    [self setTopView:nil];
    [self setLacationTextField:nil];
    [self setTeamView:nil];
    [self setShareLabel:nil];
    [super viewDidUnload];
}


//点击拍照
- (IBAction)didClickCamere:(UIButton *)sender {
    CameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:^{
        NSLog(@"hah");
    }];
}

//点击涂鸦
- (IBAction)didClickTuya:(UIButton *)sender; {
    
    TuYaViewController *tuyaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TuYaViewController"];
    tuyaVC.delegate = self;
    [self presentViewController:tuyaVC animated:YES completion:^{
        NSLog(@"tuya");
    }];
    
}

//点击地点
- (IBAction)didClickPlace:(UIButton *)sender
{
    [Singleton instance].mapInRight = NO;
    MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self presentModalViewController:mapVC animated:YES];
}


- (IBAction)didClickDownloadTest:(UIButton *)sender
{
    [[SelectManager defaultManager]downloadRecentShare];
}

//点击分享
- (IBAction)didClickShare:(UIButton *)sender
{
    [Singleton instance].isUploadingShare = YES;
    [ShareManager defaultManager].shareContents = self.shareContent.text;
    [[DiandianCoreDataManager shareDiandianCoreDataManager] create_locality_share];
    [self updateShare];
}
-(void)updateShare
{
//    [ShareManager defaultManager].shareContents = self.shareContent.text;
    [[ShareManager defaultManager] uploadWithCompletionBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    if ([Singleton instance].isUploading == YES) {
        self.uploadProgress.hidden = NO;
        self.shareLabel.hidden = YES;
    }
}

- (IBAction)didClickRecoverKeyboard:(UIButton *)sender
{
    [self.shareContent resignFirstResponder];
}

- (IBAction)didClickRedio:(UIButton *)sender
{
    RecordViewController *recordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    [self presentViewController:recordVC animated:YES completion:^{
        nil;
    }];
}
- (void)setProgress:(float)progress
{
    if (progress == 1.0f) {
        self.uploadProgress.hidden = YES;
        self.shareLabel.hidden = NO;
    }
}

#pragma mark TuYaDelegate
-(void)didFinishTuYa
{
    //    self.shareImage.image = image;
    self.shareImage.image = [UIImage imageWithContentsOfFile:[ShareManager defaultManager].tempImagePath];
    NSLog(@"ninininininininininininininini%@",[ShareManager defaultManager].tempImagePath);
}
-(void)didFinishImage:(UIImage *)CurrentImage
{
    self.shareImage.image = CurrentImage;
}

-(void)didFinishPickImage:(NSString *)imagePath
{
    self.shareImage.image = [UIImage imageWithContentsOfFile:[ShareManager defaultManager].tempImagePath];
}



#pragma mark - TextView Delegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}


@end
