//
//  RecordViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "RecordViewController.h"
#import "ShareManager.h"
#import "ShareViewController.h"
#import "lame.h"
#import "Singleton.h"


@interface RecordViewController ()

@end

@implementation RecordViewController
{
    NSMutableData *mutableData;
    NSString *soundsPath;
    NSString *path;
    NSString *mp3FilePath;
}
static RecordViewController *s_RecordViewController = nil;
+(RecordViewController *)defaultManager
{
    @synchronized(self)
    {
        if (s_RecordViewController == nil) {
            s_RecordViewController = [[RecordViewController alloc]init];
            
        }
        
    }
    return s_RecordViewController;
}
@synthesize soundsData = _soundsData;
@synthesize btn;
//@synthesize imageView = _imageView;
@synthesize playBtn = _playBtn;
@synthesize avPlay = _avPlay;


-(void)awakeFromNib
{
    [super awakeFromNib];
    mp3FilePath = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
    }
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBackground.png"]];
    self.imageView.image = [UIImage imageNamed:@"record_animate.png"];
    [self soundsAtDocumentPath];
    [self audio];
    [self.btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.btn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
    [self.playBtn addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchDown];
}

- (void)playRecordSound:(id)sender
{
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[RecordViewController defaultManager].urlPlay error:nil];
    NSLog(@"%@",[RecordViewController defaultManager].urlPlay);
    self.avPlay = player;
    [self.avPlay play];
}

- (void)btnDown:(id)sender
{
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
    
    //设置定时检测
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
//创建sounds文件夹
-(NSString *)soundsAtDocumentPath
{
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [documents lastObject];
    soundsPath = [documentsPath stringByAppendingString:@"/sounds"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:soundsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:soundsPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return soundsPath;
}

- (void)btnUp:(id)sender
{
    [recorder stop];
    [timer invalidate];
    [NSThread detachNewThreadSelector:@selector(audio_PCMtoMP3) toTarget:self withObject:nil];

    return;
    double cTime = recorder.currentTime;
    if (cTime > 2) {//如果录制时间<2 不发送
        NSDate *date = [NSDate date];
        NSString *str = [soundsPath stringByAppendingFormat:@"/%@.pcm",[date description]];
        NSLog(@"省社让那个%@",str);
        NSURL *url = [NSURL fileURLWithPath:str];
        self.soundsData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent: str];
        NSLog(@"%@",filePath);
        [self.soundsData writeToFile:filePath atomically:YES];

    }else {
        //删除记录的文件
        [recorder deleteRecording];
        //删除存储的
    }
    
    
}
- (void)btnDragUp:(id)sender
{
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    
}
- (void)audio
{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init] ;
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
//    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    NSDate *date = [NSDate date];
    NSString *str = [soundsPath stringByAppendingFormat:@"/%@.pcm",[date description]];
    path = [str copy];
    NSURL *url = [NSURL fileURLWithPath:str];
    _urlPlay = url;
    [RecordViewController defaultManager].urlPlay = url;
    NSError *error;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];

    [avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [avSession setActive:YES error:nil];
    
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}


-(void)audio_PCMtoMP3
{
    [Singleton instance].isTransforming = ![Singleton instance].isTransforming;
    NSString *mp3FileName = @"test.mp3";
    
    mp3FilePath = [soundsPath stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([path cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        NSLog(@"MP3生成成功: %@",mp3FilePath);
        [Singleton instance].isTransforming = ![Singleton instance].isTransforming;
        NSLog(@"%d",[Singleton instance].isTransforming);
    }
    
}


- (void)detectionVoice
{
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.03) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.03<lowPassResults<=0.07) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.07<lowPassResults<=0.12) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.12<lowPassResults<=0.17) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.17<lowPassResults<=0.22) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.22<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.27<lowPassResults<=0.32) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.32<lowPassResults<=0.37) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.37<lowPassResults<=0.42) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.42<lowPassResults<=0.47) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.47<lowPassResults<=0.52) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.52<lowPassResults<=0.57) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.57<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setImageView:nil];
    [self setBtn:nil];
    [self setPlayBtn:nil];

    [super viewDidUnload];
}


- (IBAction)didClickShare:(UIButton *)sender
{
//    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
//    [self presentViewController:shareVC animated:YES completion:^{
//        nil;
//    }];
    if ([mp3FilePath isEqualToString:@""]) {
        return;
    }
    
    if ([Singleton instance].isTransforming ) {
        return;
    }
    
    [ShareManager defaultManager].inPutSoundsPath = mp3FilePath;
    NSLog(@"%@",mp3FilePath);
    [self dismissViewControllerAnimated:YES completion:^{
        if ([Singleton instance].fromRecord)
        {
            [self.delegate  recordGoToShare];
        }
    }];
//    [self.navigationController pushViewController:shareVC animated:YES];
    
    
    
}



- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
@end
