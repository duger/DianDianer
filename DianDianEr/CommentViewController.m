//
//  CommentViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-11-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "CommentViewController.h"
#import "ShareManager.h"
#import "CheckCell.h"
#import "Share.h"
#import "NCMusicEngine.h"
#import "Mp3PlayerButton.h"
#import "UIImageView+WebCache.h"
#import "Singleton.h"
#import "CommentAndReplyCell.h"
#import "Reply.h"


@interface CommentViewController ()


@end

@implementation CommentViewController
{
    NCMusicEngine   *_player;
    CGFloat height;
    
    NSMutableArray *shareArray;          //所有的share
    NSMutableArray *commentArray;        //与shareID对应的所有的评论
    NSMutableArray *replytArray;         //与评论对应的所有的回复

//    
//    NSMutableArray *commentToshare;      //一条分享下的所有评论
//    NSMutableArray *replyTocomment;      //一条评论下的所有回复
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)awakeFromNib
{
   
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground.png"]];
    [self.aTableView registerClass:[CheckCell class] forCellReuseIdentifier:@"CheckCell"];
    [self.aTableView registerNib:[UINib nibWithNibName:@"CheckCell" bundle:nil] forCellReuseIdentifier:@"CheckCell"];
    
    [self.aTableView registerClass:[CommentAndReplyCell class] forCellReuseIdentifier:@"CommentAndReplyCell"];
    [self.aTableView registerNib:[UINib nibWithNibName:@"CommentAndReplyCell" bundle:nil] forCellReuseIdentifier:@"CommentAndReplyCell"];
    self.aTableView.backgroundColor = [UIColor clearColor];
    self.aTableView.dataSource = self;
    self.aTableView.delegate = self;
    self.content.delegate = self;
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
//    commentToshare = [[NSMutableArray alloc] init];
//    replyTocomment = [[NSMutableArray alloc] init];
    replytArray = [[NSMutableArray alloc]init];
    commentArray = [NSMutableArray arrayWithArray:[self.shareFromFirstView.shareToComment allObjects]];
    for (Comment* aComment in commentArray) {
        NSArray *replyArr = [NSArray arrayWithArray:[aComment.commentToReply allObjects]];
        [replytArray addObject:replyArr];
    }
    NSLog(@"%@",[commentArray description]);
    NSLog(@"%@",[replytArray description]);
    
    
    
    //随意点击去键盘
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self.content action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tapGes];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    


}

#pragma mark - 键盘收放

//键盘显示的时候调整toolbar的位置
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    CATransition *animation = [CATransition animation];
	animation.duration = animationDuration;
	animation.delegate = self;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.type = kCATransitionPush;
	animation.subtype = kCATransitionFromTop;
    
	[[self.toolBar layer] addAnimation:animation forKey:nil];
    
    self.toolBar.frame = CGRectMake(0 ,self.view.bounds.size.height - keyboardHeight - self.toolBar.bounds.size.height ,320,self.toolBar.bounds.size.height);
    
    
    if (height < 428) {
        self.aTableView.frame = CGRectMake(0, self.view.bounds.size.height-keyboardHeight-height-self.toolBar.bounds.size.height, self.aTableView.bounds.size.width, self.aTableView.bounds.size.height);
    }
    else{
//    self.aTableView.contentInset = UIEdgeInsetsMake(0, 0, height-self.aTableView.bounds.size.height + self.toolBar.bounds.size.height, 0);
    
    NSLog(@"=======%f====%f",height-self.aTableView.bounds.size.height + self.toolBar.bounds.size.height ,height);
//    [self.aTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
//键盘隐藏之后调整toolbar位置
-(void)keyboardHidden:(NSNotification *)notification
{
    self.toolBar.frame = CGRectMake(0, self.view.bounds.size.height, 320, self.toolBar.bounds.size.height);
    if (height < 428) {
        self.aTableView.frame = CGRectMake(0, self.topView.bounds.size.height + 22, self.aTableView.bounds.size.width, self.aTableView.bounds.size.height);
    }
    else{
//    self.aTableView.contentInset = UIEdgeInsetsMake(0, 0, height-self.aTableView.bounds.size.height - 206 , 0);
//    [self.aTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark UITextField Delegate-
//点击return 键盘收回
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  TableView Delegate-
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return replytArray.count+1;
}

-(CGRect)getShareLabelSize:(NSString *)share
{
    
    CGSize max = CGSizeMake(300, 1000.0f);
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:share];
    
    CGRect labelSize = [attributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    labelSize.size.height *= 2;
    
    return labelSize;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [dateFormatter stringFromDate:self.shareFromFirstView.s_createdate];

    if (indexPath.row == 0)
    {
        NSString *cellIdentifier = @"CheckCell";
        CheckCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.headImage.image = [UIImage imageNamed:@"face_test.png"];
        cell.userName.text = self.shareFromFirstView.s_user_id;
        cell.shareTime.text = str;
        cell.shareAddress.text = self.shareFromFirstView.s_locationName;
        cell.shareContent.text = self.shareFromFirstView.s_content;
        cell.shareContent.numberOfLines = 0;
        cell.shareContent.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.shareContent.backgroundColor = [UIColor redColor];
        CGRect labelRect = [self getShareLabelSize:self.shareFromFirstView.s_content];
        cell.shareContent.frame = CGRectMake(16 , 60, 300, labelRect.size.height);
        [cell.commentButton addTarget:self action:@selector(didClickComment) forControlEvents:UIControlEventTouchUpInside];
        cell.commentButton.titleLabel.text = @"举报";
        if ([self.shareFromFirstView.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"])
        {
            
        }
        else
        {
            NSURL *url = [NSURL URLWithString:self.shareFromFirstView.s_image_url];
            [cell.shareImage1 setImageWithURL:url];
        }
        if ([self.shareFromFirstView.s_sound_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds"])
        {
            cell.playButton.hidden = YES;
        }
        else
        {
            cell.playButton.hidden = NO;
            cell.playButton.mp3URL = [NSURL URLWithString:self.shareFromFirstView.s_sound_url];
            [cell.playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        }
    return cell;
    }
    static NSString *cellIdentifier = @"CommentAndReplyCell";
    CommentAndReplyCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.replyButton addTarget:self action:@selector(didClickReply:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.commentImage.image = [UIImage imageNamed:@"face_test.png"];
    
    Comment *aComment = [commentArray objectAtIndex:indexPath.row -1];
    
    cell.commentUserName.text = aComment.c_user_id;
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm"];
    cell.commentDate.text = [formatter stringFromDate:aComment.c_date];
    cell.commentContent.text = aComment.c_content;
    cell.commentContent.numberOfLines = 0;
    cell.commentContent.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSLog(@"%@",aComment.c_content);
    return cell;
}
//cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CGFloat textHeight = 0.0f;
        CGFloat imageHeight = 0.0f;
        if (!self.shareFromFirstView)
        {
            return 0;
        }
        else
        {
            NSString *text = self.shareFromFirstView.s_content;

            CGRect labelsize = [self getShareLabelSize:text];
            textHeight = labelsize.size.height;
            if ([self.shareFromFirstView.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
                height +=textHeight + 125;
                return textHeight + 115;
            }
            
            imageHeight = 343.0f;
        }
        height += textHeight + imageHeight + 150.0;
        return textHeight + imageHeight + 140.0;
    }
    else
        height += 50.0;
    return 100.0;
}
#pragma mark - 点击查看单元格上的评论按钮
-(void)didClickComment
{
//    self.sendButton.title = @"评论";
//    [self.content becomeFirstResponder];
    
    self.sendButton.title = @"举报";
    
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:@"" status:@"举报中"];
    [NSTimer scheduledTimerWithTimeInterval:(arc4random()%200)/100.0f target:self selector:@selector(didMissProgressHUD) userInfo:nil repeats:NO];

}

-(void)didMissProgressHUD
{
    [MMProgressHUD dismissWithSuccess:@"举报成功"];
}

#pragma mark -didClickPlayMp3Button-

- (void)playAudio:(Mp3PlayerButton *)button
{
    if (_player == nil) {
        _player = [[NCMusicEngine alloc] init];
        _player.delegate = self;
    }
    
    if ([_player.button isEqual:button]) {
        if (_player.playState == NCMusicEnginePlayStatePlaying) {
            [_player pause];
        }
        else if(_player.playState==NCMusicEnginePlayStatePaused){
            [_player resume];
        }
        else{
            [_player playUrl:button.mp3URL];
        }
    } else {
        [_player stop];
        _player.button = button;
        [_player playUrl:button.mp3URL];
    }
}

#pragma mark -didReplyButton

-(void)didClickReply:(UIButton *)sender
{
    self.sendButton.title = @"回复";

    [self.content becomeFirstResponder];
    CommentAndReplyCell *cell = (CommentAndReplyCell *)sender.nextResponder.nextResponder.nextResponder;
    [ShareManager defaultManager].replyToID = cell.commentUserName.text;
    [ShareManager defaultManager].replyCommentID = cell.commentID;
}




#pragma mark - didClickSend
- (IBAction)didClickSend:(UIBarButtonItem *)sender
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    if ([self.sendButton.title isEqualToString:@"评论"])
    {
        [Singleton instance].isUploadingComment = YES;
      
        [ShareManager defaultManager].creatDate = [date  dateByAddingTimeInterval: interval];
        [ShareManager defaultManager].commentID = [NSString stringWithFormat:@"%@+%f",self.shareFromFirstView.s_id,[[ShareManager defaultManager].creatDate timeIntervalSince1970]];
        [ShareManager defaultManager].shareID = self.shareFromFirstView.s_id;
        [ShareManager defaultManager].commentContent = self.content.text;
        [ShareManager defaultManager].userID = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
        //上传到服务器
        [[ShareManager defaultManager] uploadComment];
        [self.content resignFirstResponder];
        self.content.text = @"";
    }
    if ([self.sendButton.title isEqualToString:@"回复"])
    {
        
        [Singleton instance].isUploadingReply  = YES;
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate: date];
        [ShareManager defaultManager].replyDate = [date  dateByAddingTimeInterval: interval];
        [ShareManager defaultManager].replyContent = self.content.text;
        [ShareManager defaultManager].replyFromID = [[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyJID];
        [ShareManager defaultManager].replyID = [NSString stringWithFormat:@"%@+%@+%f",self.shareFromFirstView.s_id,[ShareManager defaultManager].replyFromID,[[ShareManager defaultManager].replyDate timeIntervalSince1970]];
        [[ShareManager defaultManager] uploadReply];
        [self.content resignFirstResponder];
        self.content.text = @"";
    }
    
}
         
- (IBAction)didClickBack:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

@end
