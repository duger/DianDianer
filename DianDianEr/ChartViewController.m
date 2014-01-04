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

    
    XMPPStream *xmppStream;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
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
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toSomeOne = [XMPPManager instence].toSomeOne;

//    self.xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    self.xmppStream = [XMPPManager instence].xmppStream;
//    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[XMPPManager instence]setDelegate:self];
    
    //头像
    selfHeadImage =[[UIImage alloc]init];
    selfHeadImage = [[XMPPManager instence].headImages objectForKey:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
    friendHeadImage = [[UIImage alloc]init];
    friendHeadImage = [[XMPPManager instence].headImages objectForKey:self.toSomeOne];
    NSLog(@"%@",self.toSomeOne);
    
    //获得好友聊天记录
    NSArray *allMessagesArr = [[XMPPManager instence] startLoadMessages:self.toSomeOne];
    [self getPopChartList:allMessagesArr];
    
    //下拉查看更多
    _header = [[MJRefreshHeaderView alloc]init];
    [_header setScrollView:self.tableView];
    _header.delegate = self;
    [_header.arrowImage removeFromSuperview];


    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic.png"]];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    UIImage *image = [UIImage imageNamed:@"backitem.png"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:backBtn ];
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    //    self.phraseViewController.chatViewController = self;
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"资料"
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:nil];
	self.navigationItem.rightBarButtonItem = rightItem;
    
    
    NSMutableString *tempStr = [[NSMutableString alloc] initWithFormat:@""];
    self.messageString = tempStr;
    
    
	NSDate   *tempDate = [[NSDate alloc] init];
	self.lastTime = tempDate;
    
    
    
    
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


-(void)dealloc
{
    [self.xmppStream removeDelegate:self];
    self.xmppStream = nil;
    self.xmppMessageArchivingCoreDataStorage = nil;
    [_header free];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveHistory:(XMPPMessage *)message {
    NSManagedObjectContext *context = [self.xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    XMPPMessageArchiving_Message_CoreDataObject *messageObject = [NSEntityDescription insertNewObjectForEntityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];//NSManagedObject
    [messageObject setBareJid:message.to];
    [messageObject setBareJidStr:message.toStr];
    [messageObject setBody:message.body];
    [messageObject setMessage:message];
    [messageObject setTimestamp:[NSDate date]];
    [messageObject setIsOutgoing:YES];
    [messageObject setStreamBareJidStr:message.body];
    NSError *error ;
    if (![context save:&error]) {
        NSLog(@"data not save to database : %@",error.description);
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPMessageArching Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)getMessagesFromFetchedRequest
{
    fetchedMessageResultsController = [[XMPPManager instence]fetchedMessageArchivingResultsController];
    id<NSFetchedResultsSectionInfo> messages = [[fetchedMessageResultsController sections]objectAtIndex:0];
    NSArray *arr = [messages objects];
    [self getPopChartList:arr];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"did send message : %@",message.description);
    [self saveHistory:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"didReceiveMessage ： %@",message.description);
	// A simple example of inbound message handling.
    
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
        
        Messages *aMessage = [[DiandianCoreDataManager shareDiandianCoreDataManager]createAMessage];
        [aMessage setChart_content:body];
        [aMessage setChart_date:[NSDate date]];
        [aMessage setFrom_jid:[message from].user];
        [aMessage setTo_jid:[message to].user];
        [[DiandianCoreDataManager shareDiandianCoreDataManager]addMessage:aMessage intoChartLists:[XMPPManager instence].chartListsForCurrentUser];
        
        
        if ([message isOfflineMessageWithBody]) {
            
        }
        
        
        if ([body base64DecodedData]) {
            NSData *data = [body base64DecodedData];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/test.amr"];
            NSLog(@"path : %@",path);
            BOOL write = [data writeToFile:path atomically:YES];
            if (write) {
                NSLog(@"yes");
            }else{
                NSLog(@"no");
            }
        }
        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
            //			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
            //                                                                message:body
            //                                                               delegate:nil
            //                                                      cancelButtonTitle:@"Ok"
            //                                                      otherButtonTitles:nil];
            //			[alertView show];
            UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",body]
                                           from:NO];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.toSomeOne, @"text", @"other", @"speaker", chatView, @"view", nil]];
            
            [self.tableView reloadData];
            if (self.chatArray.count > 5) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
                                          animated:YES];
            }
            
		}
		else
		{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiveChat
                                                                object:self userInfo:nil];
            
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

//- (NSManagedObjectContext *)managedObjectContext_capabilities
//{
//	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
//}



#pragma mark Table View DataSource Methods
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
    NSLog(@"%d",cell.kContentView.subviews.count);
    
    if (cell.kContentView.subviews.count != 0) {
        for (id obj in cell.kContentView.subviews) {
            [obj removeFromSuperview];
            
        }
    }
    
	if ([[self.chatArray objectAtIndex:[indexPath row]] isKindOfClass:[NSDate class]]) {
		// Set up the cell...
		NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yy-MM-dd HH:mm"];
		NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:[self.chatArray objectAtIndex:[indexPath row]]]];
        UITextField *timeTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
        [timeTF setCenter:CGPointMake(cell.kContentView.center.x, cell.kContentView.center.y)];
        [timeTF setTextAlignment:NSTextAlignmentCenter];
        [timeTF setText:timeString];
        [timeTF setFont:[UIFont systemFontOfSize:10.0f]];

        
		[cell.kContentView addSubview:timeTF];
		
        
	}else {
		// Set up the cell...
		NSDictionary *chatInfo = [self.chatArray objectAtIndex:[indexPath row]];
		UIView *chatView = [chatInfo objectForKey:@"view"];
        //        chatView.backgroundColor = [UIColor blueColor];
//        if (cell.kContentView.subviews.count > 1) {
//            for (id obj in cell.kContentView.subviews) {
//                if ([obj isKindOfClass:[UITextField class]] ) {
//                    cell.chartTextField.text = @"";
//                    continue;
//                }
//                UIView *chartView = (UIView *)obj;
//                [chartView removeFromSuperview];
//            }
//        }

        
		[cell.kContentView addSubview:chatView];
	}
    return cell;
}
#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.enterTextField resignFirstResponder];
}


/*
 生成泡泡UIView
 */
#pragma mark - Table view methods  生成泡泡UIView
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf){
        [headImageView setImage:selfHeadImage];
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f );
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
	else{
        [headImageView setImage:friendHeadImage];
        returnView.frame= CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    
    
	return cellView;
    
}



#pragma mark TextField Delegate Methods
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

#pragma mark MJRefresh Delegate -进入刷新状态就会调用
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        
        
        // 2秒后刷新表格
        [self performSelector:@selector(reloadChartList) withObject:nil afterDelay:2];
    }
   
//    [header endRefreshing];
    
    
}

-(void)reloadChartList
{
    NSInteger currentIndex = self.chatArray.count;
    NSArray *allMessagesArr = [[XMPPManager instence] loadMoreMessages:currentIndex andToJid:self.toSomeOne];
    NSLog(@"%@",self.toSomeOne);
    [self getPopChartList:allMessagesArr];
    if (currentIndex > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count] - 1 - currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
//    [self.tableView reloadData];
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



- (IBAction)didClickButton:(UIBarButtonItem *)sender {
    NSString *messageStr = self.enterTextField.text;
    //气泡内文字
    [self.messageString appendString:self.enterTextField.text];
    if ([messageStr isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        
    }else
    {
        [self sendMessage:messageStr];
        if (self.chatArray.count > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated:YES];
        }
    }
    
    
    self.enterTextField.text = @"";
    [self.messageString setString:@""];
    
    [self.enterTextField resignFirstResponder];
    
    
}

-(void)sendMessage:(NSString *)messageStr
{
   
    //当前时间
    NSDate *nowTime = [NSDate date];
    
        Messages *aMessage = [[DiandianCoreDataManager shareDiandianCoreDataManager]createAMessage];
        [aMessage setChart_content:messageStr];
        [aMessage setChart_date:nowTime];
        [aMessage setFrom_jid:[XMPPManager instence].xmppStream.myJID.user];
        [aMessage setTo_jid:self.toSomeOne];
        NSLog(@"%@",[XMPPManager instence].xmppStream.myJID.user);
        
        NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
        [xmlBody setStringValue:self.enterTextField.text];
        NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
        [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
        [xmlMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@124.205.147.26",self.toSomeOne]];
        [xmlMessage addChild:xmlBody];
        
        [self.xmppStream sendElement:xmlMessage];
        
        [[DiandianCoreDataManager shareDiandianCoreDataManager]addMessage:aMessage intoChartLists:[XMPPManager instence].chartListsForCurrentUser];
        //    NSMutableDictionary *msgAsDictionary = [[NSMutableDictionary alloc] init];
        //    [msgAsDictionary setObject:self.messageTextField.text forKey:@"message"];
        //    [msgAsDictionary setObject:@"you" forKey:@"sender"];
        //    [self.messages addObject:msgAsDictionary];
        NSLog(@"From: You, Message: %@", self.enterTextField.text);
    

    if ([self.chatArray lastObject] == nil) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
	
    
    // 发送后生成泡泡显示出来
	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
	if (timeInterval >5) {
		self.lastTime = nowTime;
		[self.chatArray addObject:nowTime];
	}
    UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",messageStr]
								   from:YES];
	[self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:messageStr, @"text", @"self", @"speaker", chatView, @"view", nil]];
    NSLog(@"个数 %d %@",self.chatArray.count ,self.chatArray);
	[self.tableView reloadData];

}



- (IBAction)didClickBack:(UIButton *)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -private method

//获得初始
-(void)getPopChartList:(NSArray *)allMessagesArr
{
    [self.chatArray removeAllObjects];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *aMessage in allMessagesArr) {
        if (![aMessage isOutgoing]) {
            UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",aMessage.body]from:YES];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:aMessage.body, @"text", @"self", @"speaker", chatView, @"view", nil]];
        }else{
            UIView *chatView = [self bubbleView:[NSString stringWithFormat:@"%@",  aMessage.body]from:NO];
            [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:aMessage.body, @"text", @"other", @"speaker", chatView, @"view", nil]];
        }
    }
    
    [self.tableView reloadData];
}


- (void)viewDidUnload {
    [self setTopView:nil];
    [super viewDidUnload];
}
@end
