//
//  ShareViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareManager.h"
#import "CameraViewController.h"
#import "TuYaViewController.h"
#import "NCMusicEngine.h"
#import "RecordViewController.h"
@interface ShareViewController : UIViewController<ShareManagerDelegate,CameraViewControllerDelegate,UITextViewDelegate,TuYaViewControllerDelegate,RecordViewControllerDelegate,AVAudioRecorderDelegate,DiandianCoreDataManagerDelegate>

-(void)didFinishTuYa:(UIImage *)image;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
- (IBAction)didClickBack:(UIBarButtonItem *)sender;
- (IBAction)didClickImageUploadTest:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIProgressView *uploadProgress;
- (IBAction)didClickCamere:(UIButton *)sender;
- (IBAction)didClickTuya:(UIButton *)sender;
- (IBAction)didClickPlace:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextView *shareContent;
@property (strong, nonatomic) IBOutlet UIImageView *shareImage;

@property(strong ,nonatomic) UIImage *currentImage;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UITextField *lacationTextField;
@property (strong, nonatomic) IBOutlet UIView *teamView;

- (IBAction)didClickDownloadTest:(UIButton *)sender;
- (IBAction)didClickShare:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel;

- (IBAction)didClickRecoverKeyboard:(UIButton *)sender;
- (IBAction)didClickRedio:(UIButton *)sender;
-(void)updateShare;
-(void)reloadViews;

@end
