//
//  RecordViewController.h
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@protocol RecordViewControllerDelegate <NSObject>
-(void)recordGoToShare;
@end
@interface RecordViewController : UIViewController<AVAudioRecorderDelegate>
{
    AVAudioRecorder *recorder;
    NSTimer *timer;
//    NSURL *urlPlay;
    
}
+(RecordViewController *)defaultManager;

@property (strong, nonatomic) IBOutlet UIView *topView;
- (IBAction)didClickShare:(UIButton *)sender;

- (IBAction)didClickBack:(UIBarButtonItem *)sender;
@property (retain, nonatomic) NSURL *urlPlay;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) id <RecordViewControllerDelegate> delegate;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property(nonatomic,retain) NSData *soundsData;
@end
