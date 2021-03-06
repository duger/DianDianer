//
//  FirstViewController.m
//  side2
//
//  Created by 王超 on 13-10-17.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "FirstViewController.h"
#import "ShareViewController.h"
#import "CameraViewController.h"
#import "RecordViewController.h"
#import "TuYaViewController.h"
#import "CustomItem.h"
#import "SidebarViewController.h"
#import "AwesomeMenuItem.h"
#import "AwesomeMenu.h"
#import "KxMenu.h"
#import "MapViewController.h"
#import "HomePageCell.h"
#import "UIImageView+WebCache.h"
#import "Mp3PlayerButton.h"
#import "Singleton.h"
#import "MapViewController.h"
#import "CommentViewController.h"
#import "Change.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"


@interface FirstViewController ()
-(AwesomeMenu *)_createAnAwesomeMenu;

- (void)downloadImage:(NSString *)imgURL forIndexPath:(NSIndexPath *)indexPath;

@end

static int line = 5;
static int indexCount = 1;
@implementation FirstViewController
{
    AwesomeMenuItem *starMenuItem1;
    AwesomeMenuItem *starMenuItem2;
    AwesomeMenuItem *starMenuItem3;
    AwesomeMenuItem *starMenuItem4;
    AwesomeMenu *menu ;
    NSMutableArray *userArray;
    Mp3PlayerButton *playButton;
    NCMusicEngine *_player;
    UIActivityIndicatorView   *aView;
    
    UITableView         *aTableView;
    
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPHONE5) {
        [self.view setFrame:CGRectMake(0, 60, self.view.bounds.size.width, ScreenHeight)];
    }else{
        [self.view setFrame:CGRectMake(0,60, self.view.bounds.size.width, ScreenHeight)];
    }
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    
    self.view.backgroundColor = [UIColor clearColor];
    aTableView = [[UITableView alloc] init];
    [aTableView registerClass:[HomePageCell class] forCellReuseIdentifier:@"HomePageCell"];
    [aTableView registerNib:[UINib nibWithNibName:@"HomePageCell" bundle:nil] forCellReuseIdentifier:@"HomePageCell"];

    
    aTableView.backgroundColor = [UIColor clearColor];

//    aTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground.png"]];
    aTableView.frame = CGRectMake(0,0 , 320, kHEIGHT_SCREEN - self.topView.frame.origin.y - self.topView.frame.size.height-16);
    [self.containView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"i5mainbackground.png"]]];
    [self.containView addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    
    
    
    
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.delegate = self;
    _header.scrollView = aTableView;
    [_header.arrowImage removeFromSuperview];
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.delegate = self;
    _footer.scrollView = aTableView;
    
    
    self.shareArray = [NSMutableArray arrayWithArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] all_share]];
    indexCount = self.shareArray.count;

    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    
    //多功能菜单
     menu = [self _createAnAwesomeMenu];
    [menu setDelegate:self];
    [self.view addSubview:menu];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //下载数据库中的所有 分享
//    [[SelectManager defaultManager] downloadRecentShare];
//    self.shareArray = [NSMutableArray arrayWithArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] all_share]];
    
    //下载数据库中的所有 赞
//    [[SelectManager defaultManager] downloadRecentGood];
//    self.commentArray = [NSMutableArray arrayWithArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] allComment]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cicCLickZuoBian:(CustomItem *)sender {
    if (!sender.showLeft) {
        if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
            [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionLeft];
        }
        sender.showLeft = !sender.showLeft;
        return;
    }
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionNone];
    }
    sender.showLeft = !sender.showLeft;
}

- (IBAction)didClickRight:(CustomItem *)sender
{
    if (!sender.showRight) {
        if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
            [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionRight];
        }
        sender.showRight = !sender.showRight;
        return;
    }
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionNone];
    }
    sender.showRight = !sender.showRight;
}

- (IBAction)showMenu:(UIButton *)sender
{
    NSLog(@"%@",menu.menusArray);
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"分类浏览"
                     image:nil
                    target:nil
                    action:NULL],
      //      [KxMenuItem menuItem:@"地图" image:nil target:self action:@selector(didClickGoToMap)],
      [KxMenuItem menuItem:@"默认"
                     image:[UIImage imageNamed:@"house.png"]
                    target:self
                    action:@selector(allShare)],
      
      [KxMenuItem menuItem:@"心情"
                     image:[UIImage imageNamed:@"page.png"]
                    target:self
                    action:@selector(textShare)],
      
      [KxMenuItem menuItem:@"图片"
                     image:[UIImage imageNamed:@"image.png"]
                    target:self
                    action:@selector(imageShare)],
      
      [KxMenuItem menuItem:@"语音"
                     image:[UIImage imageNamed:@"sound.png"]
                    target:self
                    action:@selector(soundShare)],
      
      //      [KxMenuItem menuItem:@"附近的人"
      //                     image:[UIImage imageNamed:@"search_icon"]
      //                    target:self
      //                    action:@selector(pushMenuItem:)],
      //
      //      [KxMenuItem menuItem:@"好友圈儿"
      //                     image:[UIImage imageNamed:@"home_icon"]
      //                    target:self
      //                    action:@selector(pushMenuItem:)],
      
      ];
    NSLog(@"%@",sender.titleLabel.text);
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0f];
    
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}
-(void)allShare
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObjectsFromArray:[[DiandianCoreDataManager shareDiandianCoreDataManager]all_share]];
    self.shareArray = array;
    [aTableView reloadData];
}
-(void)textShare
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObjectsFromArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] textShare] ];
    self.shareArray = array;
    [aTableView reloadData];
}
-(void)imageShare
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObjectsFromArray: [[DiandianCoreDataManager shareDiandianCoreDataManager] imageShare]];
    self.shareArray = array;
    [aTableView reloadData];
}
-(void)soundShare
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [array addObjectsFromArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] soundShare]];
    self.shareArray = array;
    [aTableView reloadData];
}
-(void)didClickGoToMap
{
    MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark - AwesomeMenu Methods
-(AwesomeMenu *)_createAnAwesomeMenu
{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    
    UIImage *star1 = [UIImage imageNamed:@"chart.png"];
    UIImage *star2 = [UIImage imageNamed:@"photo.png"];
    UIImage *star3 = [UIImage imageNamed:@"audio.png"];
    UIImage *star4 = [UIImage imageNamed:@"paint.png"];
    
    starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                          highlightedImage:storyMenuItemImagePressed
                                              ContentImage:star1
                                   highlightedContentImage:nil];
    starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                          highlightedImage:storyMenuItemImagePressed
                                              ContentImage:star2
                                   highlightedContentImage:nil];
    starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                          highlightedImage:storyMenuItemImagePressed
                                              ContentImage:star3
                                   highlightedContentImage:nil];
    starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                          highlightedImage:storyMenuItemImagePressed
                                              ContentImage:star4
                                   highlightedContentImage:nil];
    
    
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, nil];
    
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                                       highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"]
                                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
    
    AwesomeMenu *kMenu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds startItem:startItem optionMenus:menus];
   
    
    return kMenu;
}


- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"选的功能%d",idx);
    switch (idx) {
        case 0:
            [self performSelector:@selector(push_1) withObject:nil afterDelay:0.5f];
            break;
        case 1:
            [self performSelector:@selector(push_2) withObject:nil afterDelay:0.5f];
            break;
        case 2:
            [self performSelector:@selector(push_3) withObject:nil afterDelay:0.5f];
            break;
        case 3:
            [self performSelector:@selector(push_4) withObject:nil afterDelay:0.5f];
            break;
            
        default:
            break;
    }
}


-(void)push_1
{
    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    [self presentViewController:shareVC animated:YES completion:^{
        nil;
    }];

}

-(void)goToShare
{
    [Singleton instance].fromCamera = ![Singleton instance].fromCamera;
    [self push_1];
    
}
-(void)tuYaGoToShare
{
    [Singleton instance].fromTuYa = ![Singleton instance].fromTuYa;
    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    [self presentViewController:shareVC animated:YES completion:^{
        nil;
    }];
}
-(void)recordGoToShare
{
    [Singleton instance].fromRecord = ![Singleton instance].fromRecord;
    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    [self presentViewController:shareVC animated:YES completion:^{
        nil;
    }];
    
}

-(void)push_2
{
    [Singleton instance].fromCamera = ![Singleton instance].fromCamera;
    CameraViewController *photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    photoVC.delegate = self;
    [self presentViewController:photoVC animated:YES completion:nil];
}

-(void)push_3
{
    [Singleton instance].fromRecord = ![Singleton instance].fromRecord;
    RecordViewController *recordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    recordVC.delegate = self;
    [self presentViewController:recordVC animated:YES completion:nil];
}

-(void)push_4
{
    [Singleton instance].fromTuYa = ![Singleton instance].fromTuYa;
    TuYaViewController *tuYaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TuYaViewController"];
    tuYaVC.delegate = self;
    [self.navigationController presentViewController:tuYaVC animated:YES completion:nil];
}



#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    [_footer endRefreshing];
    if (self.shareArray.count < line) {
        return self.shareArray.count;
    }else
        return line;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat textHeight = 0.0f;
    CGFloat imageHeight = 0.0f;
    if (self.shareArray.count == 0)
    {
        return 0;
    }
    else
    {
        Share *share = [self.shareArray objectAtIndex:[self.shareArray count] - indexPath.row - 1 ];
        NSString *text = share.s_content;


        NSLog(@"%@",text);
        
//        HomePageCell *cell = (HomePageCell*)[tableView cellForRowAtIndexPath:indexPath];
        CGRect labelsize = [self getShareLabelSize:share];
        NSLog(@"%f-------%f",labelsize.size.height,labelsize.size.width);
        textHeight = labelsize.size.height;

        if ([share.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
            
            return textHeight + 110;
        }
        imageHeight = 40.0f;
    }
    return textHeight + imageHeight + 140;
}


-(CGRect)getShareLabelSize:(Share *)share
{
    

    CGSize max = CGSizeMake(300, 1000.0f);
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:share.s_content];
//    cell.shareLabel.attributedText = attributedString;
    NSRange range = NSMakeRange(0, attributedString.length);

//    CGRect labelSize = [share.s_content boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil];
    CGRect labelSize = [attributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    labelSize.size.height *= 2;

    return labelSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"HomePageCell";
    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    if (self.shareArray.count == 0)
    {
        return cell;
    }
    else
    {
        Share *share = [self.shareArray objectAtIndex: [self.shareArray count] - indexPath.row - 1];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str = [dateFormatter stringFromDate:share.s_createdate];
        cell.currentShare = share;
        cell.shareID = share.s_id;
        cell.timeLabel.text = str;
        cell.nameLabel.text = share.s_user_id;

        cell.shareLabel.text = share.s_content;

        CGRect labelRect = [self getShareLabelSize:share];
        cell.shareLabel.frame = CGRectMake(14, 60, 300, labelRect.size.height);
        cell.shareLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.shareLabel.numberOfLines = 0;
        cell.addressLabel.text = share.s_locationName;
        cell.headName.image = [UIImage imageNamed:@"Icon-76.png"];
        if (!share.s_image_url ) {
        }
        else
        {
            NSURL *url = [NSURL URLWithString:share.s_image_url];
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
            NSLog(@"%@",share.s_sound_url);
            [cell.playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    //给评论按钮添加点击事件
    [cell.commentButton addTarget:self action:@selector(goToComment:) forControlEvents:UIControlEventTouchUpInside];
    //给举报按钮添加点击事件
    [cell.ReportButton addTarget:self action:@selector(reportAShare:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)configureCell:(HomePageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Share *share = [self.shareArray objectAtIndex: [self.shareArray count] - indexPath.row - 1];
    if (share.s_image_url) {
        // 加载图片
        NSString *imgURL = share.s_image_url;
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgURL];
        
        //没有已经下载好的图片
        if (!cachedImage) {
            //如果当前tableview 没有在本拖动或者自由滑动
            if (!aTableView.dragging && !aTableView.decelerating) {
                //下载当前cell中的图片
                [self downloadImage:imgURL forIndexPath:indexPath];
            }
            //cell 中图片先用缓存占位图代替
            [cell.shareImage setImage:[UIImage imageNamed:@"LOG-IN.png"]];
        } else {
            //找到缓存图片，直接插缓存的图片
            [cell.shareImage setImage:cachedImage];
        }
    }

}

- (void)downloadImage:(NSString *)imgURL forIndexPath:(NSIndexPath *)indexPath
{
//    __weak typeof(self) target = self;
    __weak typeof(UITableView *) btableView = aTableView;
    //利用SDWebImage 框架提供的功能下载图片
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSUInteger receivedSize, long long expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        //保存图片
        [[SDImageCache sharedImageCache]  storeImage:image forKey:imgURL toDisk:YES];
        //延迟在主线程更新 cell 的高度
        dispatch_async(dispatch_get_main_queue(), ^{
            [btableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }];
}


- (void)loadImageForOnScreenRows
{
    NSArray *visiableIndexPathes = [aTableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visiableIndexPathes) {
        Share *share = [self.shareArray objectAtIndex: [self.shareArray count] - indexPath.row - 1];
        NSString *imgURL = share.s_image_url;
        [self downloadImage:imgURL forIndexPath:indexPath];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomePageCell *cell = (HomePageCell *) [tableView cellForRowAtIndexPath:indexPath];
    [ShareManager defaultManager].shareID = cell.shareID;
    CommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commentVC.shareFromFirstView = [self.shareArray objectAtIndex:[self.shareArray count] - indexPath.row - 1 ];

    NSLog(@"点击分享此时的分享ID%@", [[ShareManager defaultManager] shareID]);
    [self.navigationController presentViewController:commentVC animated:YES completion:^{
        nil;
    }];

}
//评论按钮的点击事件，跳转到评论页面
-(void)goToComment:(UIButton *)sender
{
    HomePageCell *cell = (HomePageCell *)sender.nextResponder.nextResponder.nextResponder.nextResponder;
    [ShareManager defaultManager].shareID = cell.shareID;
    NSLog(@"%@",[ShareManager defaultManager].shareID);
    CommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    NSLog(@"%@",sender.superview.superview.superview.superview.class);
    HomePageCell *mycell = (HomePageCell *)sender.superview.superview.superview.superview;
    commentVC.shareFromFirstView = mycell.currentShare;
    
    [self.navigationController presentViewController:commentVC animated:YES completion:^{
        nil;
    }];
}

-(void)reportAShare:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil , nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
    
}

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

- (void)viewDidUnload
{
    [self setTopView:nil];
    [super viewDidUnload];
}
#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // table view 停止拖动了
    if (!decelerate) {
        [self loadImageForOnScreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // table view 停止滚动了
    [self loadImageForOnScreenRows];
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [[SelectManager defaultManager]downloadDateFromServiceToLocal:1];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH : mm : ss.SSS";
    
    self.shareArray = [NSMutableArray arrayWithArray:[[DiandianCoreDataManager shareDiandianCoreDataManager] all_share]];
    UIButton * btn  = (UIButton *)[self.view viewWithTag:100];
    NSLog(@"%@",btn);
    if (_header == refreshView)
    {
        for (int i = 0; i<1; i++)
        {
            line +=1;
            for (int j = 0; j<1; j++) {
                [aTableView reloadData];
                if (indexCount == self.shareArray.count)
                {
                    indexCount = self.shareArray.count;
                    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经是最新数据了" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertview show];
                    [NSTimer scheduledTimerWithTimeInterval:0.5 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
                    return;
                    
                }
            }
        }
        line -=1;
    }
    
    else {
        for (int i = 0; i<5; i++) {
            line +=1;
            if (line >= self.shareArray.count)
            {
                UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经没有更多数据了" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertview show];
                line -=1;
                [NSTimer scheduledTimerWithTimeInterval:0.5 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
                return;
            }
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}



#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
        [MMProgressHUD showWithTitle:@"" status:@"举报中"];
        [NSTimer scheduledTimerWithTimeInterval:(arc4random()%200)/100.0f target:self selector:@selector(didMissProgressHUD) userInfo:nil repeats:NO];
        
        
        
    }
}

-(void)didMissProgressHUD
{
    [MMProgressHUD dismissWithSuccess:@"举报成功"];
}


- (void)dealloc
{
    [_footer free];
    [_header free];
}
@end
