//
//  ChartViewController.m
//  XMPP
//
//  Created by Duger on 13-10-22.
//  Copyright (c) 2013年 Dawn_wdf. All rights reserved.
//

#import "ChartViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "ChartCell.h"
#import "XMPP.h"
//#import "XMPPReconnect.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"

#import "XMPPManager.h"
#import "FaceViewController.h"
#import "Messages.h"

#import "MJRefreshBaseView.h"
#import "MJRefreshHeaderView.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300
#define kDidReceiveChat @"didReceiveChat"

#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

@interface ChartViewController ()
{
    //下拉刷新中
    //区分下拉刷新更新消息和收发信息更新消息
    BOOL _isMJRefreshing;
}
@end

@implementation ChartViewController
{
    
    NSString                   *_titleString;
    NSMutableString            *_messageString;
    NSString                   *_phraseString;
    NSMutableArray		       *_chatArray;
    
    UITableView                *_chatTableView;
    UITextField                *_messageTextField;
    BOOL                       _isFromNewSMS;
    FaceViewController      *_phraseViewController;
    
    NSDate                     *_lastTime;
    MJRefreshHeaderView      *_header;


    
    //头像
    UIImage *selfHeadImage;
    UIImage *friendHeadImage;
    
}

@synthesize fetchedMessageResultsController;

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
        self.chatArray = [[NSMutableArray alloc] init];
        
        //是否正在下拉刷新
        _isMJRefreshing = NO;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toSomeOne = [XMPPManager instence].toSomeOne;
    
    [[XMPPManager instence]setMessageDelegate:self];
    

    //导航栏 对方的名字
    self.toSomeOneLabel.text = self.toSomeOne.user;
    NSLog(@"%@",self.toSomeOne.bare);



    //头像
    selfHeadImage =[[UIImage alloc]init];
    selfHeadImage = [[XMPPManager instence] selfHeadImage];
    friendHeadImage = [[UIImage alloc]init];
    friendHeadImage = [[XMPPManager instence] friendHeadImage];
    NSLog(@"%@",self.toSomeOne);
    
    //获得好友聊天记录
    [self getMessagesFromFetchedRequest];
    
    //下拉查看更多
    _header = [[MJRefreshHeaderView alloc]init];
    [_header setScrollView:self.tableView];
    _header.delegate = self;
    [_header.arrowImage removeFromSuperview];
    _header.backgroundColor = [UIColor clearColor];


    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic.png"]];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];


    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mkeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mkeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mkeyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
    }
    if (self.chatArray.count > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:NO];
    }
    
    
}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [XMPPManager instence].messageDelegate = nil;
    [XMPPManager instence].fetchedMessageArchivingResultsController = nil;
    //把默认消息个数恢复为默认
    [XMPPManager instence].pageCount = kPageCount;
    //删除未读消息
    [[XMPPManager instence]removeUnReadMessageMark];
    
}

-(void)dealloc
{
    
    [_header free];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPMessageArching Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)getMessagesFromFetchedRequest
{
    self.fetchedMessageResultsController = [[XMPPManager instence]xmppMessageArchivingFetchedResultsController];
//    NSInteger max = [[fetchedMessageResultsController fetchedObjects]count];
    
//[fetchedMessageResultsController.fetchRequest setFetchOffset:(max - 10)];
//    [fetchedMessageResultsController performFetch:nil];
//    NSDictionary<NSFetchedResultsSectionInfo> *messages = [[fetchedMessageResultsController sections]objectAtIndex:0];
//    NSArray *arr = [messages objects];
  
    NSArray *arr = [fetchedMessageResultsController fetchedObjects];
    NSLog(@"%d",arr.count);
    [self getPopChartList:arr];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPMessageDelegate Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//XMPPMessageAching中查询聊天列表
//fetchedResultsController接到消息改变时回调此方法
-(void)controllerDidChangedWithFetchedMessageArchingResult:(NSFetchedResultsController *)fetchedMessageArchivingResultsController
{
    [self getMessagesFromFetchedRequest];
}



#pragma mark - Table View DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    return [self.chatArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		return 40;
	}else {
		UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
		return chatView.frame.size.height+10;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CommentCellIdentifier = @"CommentCell";
	ChartCell *cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
	if (cell == nil) {
//        cell = [[ChartCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentCellIdentifier];
        cell = [self.storyboard instantiateViewControllerWithIdentifier:@"ChartCell"];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell prepareForReuse];
        
	}
    
    if (cell.kContentView.subviews.count != 0) {
        for (id obj in cell.kContentView.subviews) {
            [obj removeFromSuperview];
            
        }
    }
    
//	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
//		// Set up the cell...
//		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
//		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
//		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
//        UITextField *timeTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
//        [timeTF setCenter:CGPointMake(cell.kContentView.center.x, cell.kContentView.center.y)];
//        [timeTF setTextAlignment:NSTextAlignmentCenter];
//        [timeTF setText:timeString];
//        [timeTF setFont:[UIFont systemFontOfSize:10.0f]];
//
//        
//		[cell.kContentView addSubview:timeTF];
//		
//        
//	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
    
		[cell.kContentView addSubview:chatView];

    return cell;
}
#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.enterTextField resignFirstResponder];
}





#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField == self.enterTextField)
	{
        //		[self moveViewUp];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.enterTextField resignFirstResponder];
    return YES;
}

#pragma mark - MJRefresh Delegate -进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        
        
        // 2秒后刷新表格
        [self performSelector:@selector(mjReloadChartList) withObject:nil afterDelay:1];
    }
    
    
}

-(void)mjReloadChartList
{
    NSInteger currentIndex = self.chatArray.count;
    _isMJRefreshing = YES;
    [XMPPManager instence].pageCount += 20;
    [self getMessagesFromFetchedRequest];
    
    
    if (currentIndex > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]  - currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }


    [_header endRefreshing];
}

#pragma mark - Responding to keyboard events
- (void)mkeyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height andDuration:animationDuration];
}


- (void)mkeyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    [self autoMovekeyBoard:0 andDuration:animationDuration];
}

-(void) autoMovekeyBoard: (float)h andDuration:(NSTimeInterval)animationDuration{
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
	animation.duration = animationDuration;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.type = kCATransitionFade;
	animation.subtype = kCATransitionFromTop;

    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
    [toolbar.layer addAnimation:animation forKey:@"chart"];
    
    if (IS_IPHONE5) {
        toolbar.frame = CGRectMake(0.0f, (float)(ScreenHeight-h-24.0), 320.0f, 44.0f);
    }else{
        toolbar.frame = CGRectMake(0.0f, (float)(ScreenHeight-h-42.0), 320.0f, 44.0f);
    }
    //	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	self.tableView.frame = CGRectMake(0, 64, 320.0f,(float)(ScreenHeight-h-95.0));
    if (self.chatArray.count > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    }
}







#pragma mark -  生成泡泡UIView
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    //气泡
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    //头像
    UIImageView *headImageView = [[UIImageView alloc] init];
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds = YES;
    
    if(fromSelf){
        [headImageView setImage:selfHeadImage];
        returnView.frame= CGRectMake(10.0f, 18.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+28.0f, returnView.frame.size.height+28.0f );
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height-50.0f, 45.0f, 45.0f);
    }
	else{
        [headImageView setImage:friendHeadImage];
        returnView.frame= CGRectMake(66.0f, 18.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+28.0f, returnView.frame.size.height+28.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(7.0f, cellView.frame.size.height-50.0f, 45.0f, 45.0f);
    }
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    
    
	return cellView;
    
}


#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSLog(@"str(image)---->%@",str);
                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                
                upX=KFacialSizeWidth+upX;
                if (X<150) X = upX;
                
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 150;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    
                    upX=upX+size.width;
                    if (X<150) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

//图文混排
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}


- (IBAction)didClickSendButton:(UIBarButtonItem *)sender {
    
    NSString *messageStr = self.enterTextField.text;
    if ([messageStr isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
    }else
    {
        [[XMPPManager instence]sendMessage:messageStr];
        
        NSLog(@"From: You, Message: %@", self.enterTextField.text);
        if (self.chatArray.count > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
        }
    }
    
    
    self.enterTextField.text = @"";

    
}





- (IBAction)didClickBack:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
    
    
    
}

#pragma mark - Private Methods

//获得初始
-(void)getPopChartList:(NSArray *)allMessagesArr
{
    [self.chatArray removeAllObjects];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *aMessage in allMessagesArr) {
        if ([aMessage isOutgoing]) {
            UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",aMessage.body]from:YES];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:aMessage.body, @"text", @"self", @"speaker", chatView, @"view", nil]];
        }else{
            UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",  aMessage.body]from:NO];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:aMessage.body, @"text", @"other", @"speaker", chatView, @"view", nil]];
        }
    }
    [self.tableView reloadData];
    if (_isMJRefreshing) {
         _isMJRefreshing = !_isMJRefreshing;
    }else
        [self reloadChartListWithAnimation];
    
   
}


-(void)reloadChartListWithAnimation
{
    NSInteger currentIndex = self.chatArray.count;
    
    
    if (currentIndex > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
    }
    [_header endRefreshing];

}

- (void)viewDidUnload {
    [self setTopView:nil];
    [super viewDidUnload];
}
@end
