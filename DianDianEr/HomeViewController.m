//
//  HomeViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-18.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "HomeViewController.h"
#import "LeftSideBarViewController.h"
#import "DiandianCoreDataManager.h"
#import "UIImageView+WebCache.h"
#import <UserCell.h>


@interface HomeViewController ()<NCMusicEngineDelegate>

@end

@implementation HomeViewController
{
    Mp3PlayerButton *playButton;
    NCMusicEngine *_player;
}

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
    self.shareArray = [[NSMutableArray alloc]init];
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
        
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
    }
    
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    self.tableView = [[UITableView alloc]init];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellReuseIdentifier:@"UserCell"];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground.png"]];
    self.tableView.frame = CGRectMake(0,  22 +self.topView.frame.size.height , 320, kHEIGHT_SCREEN - self.topView.frame.size.height-20);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.shareArray addObjectsFromArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] myShare]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shareArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textHeight = 0.0f;
    CGFloat imageHeight = 0.0f;
    Share *share = [self.shareArray objectAtIndex:[self.shareArray count] - indexPath.row - 1];

    CGRect labelsize = [self getShareLabelSize:share];
    textHeight = labelsize.size.height;
    NSLog(@"笨蛋%@",share.s_image_url);
    if ([share.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
        
        return textHeight + 135;
    }
    imageHeight = 40.0f;
    return textHeight + imageHeight + 140;
}

-(CGRect)getShareLabelSize:(Share *)share
{
    
    CGSize max = CGSizeMake(300, 1000.0f);
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:share.s_content];

    CGRect labelSize = [attributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    labelSize.size.height *= 2;
    
    return labelSize;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    
    Share *share = [self.shareArray objectAtIndex: [self.shareArray count] - indexPath.row - 1];
    NSLog(@"哈哈哈哈%@",share);
    cell.timeLabel.text = [share.s_createdate description];
    cell.nameLabel.text = share.s_user_id;
    cell.shareLabel.text = share.s_content;
    cell.shareLabel.numberOfLines = 0;
    cell.shareLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect labelRect = [self getShareLabelSize:share];
    cell.shareLabel.frame = CGRectMake( 14, 60, labelRect.size.width, labelRect.size.height);
    cell.addressLabel.text = share.s_locationName;
    NSLog(@"你你你你你你你%@",cell.timeLabel.text);
    if (!share.s_image_url ) {
    }
    else
    {
        NSURL *url = [NSURL URLWithString:share.s_image_url];
        NSLog(@"%@",url);
        [cell.shareImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"LOG-IN.png"]];
        
    }
    
    if ([share.s_sound_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds"])
    {
        cell.playButton.hidden = YES;
    }
    else
    {
        cell.playButton.hidden = NO;
        cell.playButton.mp3URL = [NSURL URLWithString:share.s_sound_url];
        [cell.playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)playAudio:(Mp3PlayerButton *)button
{
    if (_player == nil) {
        _player = [[NCMusicEngine alloc] init];
        //_player.button = button;
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

- (void)viewDidUnload {
    [self setNavigationbar:nil];
    [self setTopView:nil];
    [super viewDidUnload];
}
@end
