//
//  XMPPManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "XMPPManager.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPRosterMemoryStorage.h"
#import "XMPPvCardTemp.h"
#import "XMPPSearch.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "XMPPManager.h"
#import "Singleton.h"

#import <CFNetwork/CFNetwork.h>
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#define kMessageStep 20

@implementation XMPPManager
static XMPPManager *s_XMPPManager = nil;
+(XMPPManager *)instence
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_XMPPManager == nil) {
            s_XMPPManager = [[XMPPManager alloc]init];
            
        }
    });
    return s_XMPPManager;
}

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize turnSocket;
@synthesize jidWithResouce;
@synthesize avPlay;

@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;
@synthesize chartListsForCurrentUser;
@synthesize friendList;
@synthesize headImages;

@synthesize fetchedResultsController;
@synthesize fetchedMessageArchivingResultsController;

#define tag_subcribe_alertView 10

- (id)init
{
    self = [super init];
    if (self) {
        proxyHost = [[NSString alloc]init];
        proxyPort = [[NSString alloc]init];
        proxyJID = [[NSString alloc]init];
        
        
        jidWithResouce = [[NSString alloc] init];
        
        self.roster = [[NSMutableArray alloc]init];
        headImages = [[NSMutableDictionary alloc]init];
//        chartListsForCurrentUser = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
	[self teardownStream];
}

#pragma mark -
- (void)goOnline
{
    NSLog(@"goOnline");
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    NSLog(@"goOffline");
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)setupStream{
    xmppStream = [[XMPPStream alloc] init];
    
    [xmppStream setHostName:kHOSTNAME];
	[xmppStream setHostPort:5222];
    // Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
    //把意外断开重新连接回去！！
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
    
#if !TARGET_IPHONE_SIMULATOR
    {
        //支持后台运行，虚拟机不支持
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //      xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];

	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	//好友的详细信息  如头像
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
    
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    xmppSearch = [[XMPPSearch alloc]init];
    
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    [xmppSearch            activate:xmppStream];
    [xmppMessageArchivingModule activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [xmppSearch addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];

	
    [xmppStream setHostName:kHOSTNAME];
    [xmppStream setHostPort:5222];
	
    allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    

    
   chartListsForCurrentUser = [[DiandianCoreDataManager shareDiandianCoreDataManager]allChartListWithRecentMessagesForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
    
    //数据库调取好友列表
    
    //    self.friendList = [[NSMutableArray alloc]init];
    [self.roster removeAllObjects];
    for (ChartList *item in chartListsForCurrentUser) {
        NSRange krange = [item.chartList_id rangeOfString:@"+"];
        NSString *chartListName = [item.chartList_id substringFromIndex:krange.location + 1];
        [self.roster addObject:chartListName];
    }
//    NSLog(@"数据库调出来的好友列表%@",self.roster);
    
    //    [self setFriendsHeadImage];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark User Info
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//设置备注名
-(void)setRemak:(NSString *)remark forJID:(XMPPJID *)jid
{
    [xmppRoster setNickname:remark forUser:jid];
}

//修改个性签名
-(void)updateMySignature:(NSString *)singnatureStr
{
    XMPPvCardTemp *myVcard =[xmppvCardTempModule myvCardTemp];
    [myVcard setTitle:singnatureStr];
    [xmppvCardTempModule updateMyvCardTemp:myVcard];
    
}

//修改个人信息
-(void)updateMyvCard:(XMPPvCardTemp *)vcard
{
    [xmppvCardTempModule updateMyvCardTemp:vcard];
}

//保存修改的头像
-(void)changeHeadPhoto:(UIImage *)image
{
    XMPPvCardTemp *myVcard = [xmppvCardTempModule myvCardTemp];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [myVcard setPhoto:imageData];
    [xmppvCardTempModule updateMyvCardTemp:myVcard];
}

//显示个人头像
-(UIImage *)showOneselfHeadImage
{
    XMPPJID *userJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID],kDOMAINWITHSOURCE]];
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:userJID xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
    
    UIImage *userImage = nil;
    UIImage *oneselfImage = [[UIImage alloc]init];
    
    if (user.photo != nil) {
        userImage = user.photo;
    }
    else{
        NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
        
        if (photoData != nil) {
            userImage = [[UIImage alloc]initWithData:photoData];
            
        }else{
            userImage = [UIImage imageNamed:@"DefaultHead.png"];
        }
    }
    UIImage *defaultImage = [UIImage imageNamed:@"DefaultHead.png"];
    
    if (!CGSizeEqualToSize(defaultImage.size, user.photo.size)) {
        UIGraphicsBeginImageContext(defaultImage.size);
        CGRect imageRect = {0.0,0.0,defaultImage.size.width,defaultImage.size.height};
        [userImage drawInRect:imageRect];
        oneselfImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return oneselfImage;
    
}

//重新设置头像尺寸
- (UIImage *)resizeImage:(UIImage *)inImage
{
    UIImage *retImage = inImage;
    
    UIImage *defaultImage = [UIImage imageNamed:@"DefaultHead.png"];
    if(!CGSizeEqualToSize(defaultImage.size,inImage.size))
    {
        UIGraphicsBeginImageContext(defaultImage.size);
        CGRect imageRect = {0.0,0.0,defaultImage.size.width,defaultImage.size.height};
        [inImage drawInRect:imageRect];
        retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return  retImage;
}

-(void)setMyselfImage
{
    XMPPvCardTemp *user = xmppvCardTempModule.myvCardTemp;
    //    [headImages setObject:[self resizeImage:[UIImage imageWithData:user.photo]] forKey:xmppStream.myJID.user];
    [headImages setObject:[self showOneselfHeadImage] forKey:xmppStream.myJID.user];
}

//设置某一用户头像
-(void)setUserImage:(XMPPJID *)JID
{
    //    dispatch_block_t block = ^{
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:JID xmppStream:xmppStream managedObjectContext:[self managedObjectContext_roster]];
    UIImage *image_ = nil;
    
    if(user.photo != nil)
        image_ = user.photo;
    else
    {
        NSData *photoData = [xmppvCardAvatarModule photoDataForJID:user.jid];
        
        if(photoData != nil)
            image_ = [[UIImage alloc] initWithData:photoData];
        else
            image_ = [UIImage imageNamed:@"Icon-72.png"];
        
    }
    
    [headImages setObject:image_ forKey:JID.user];
    //    };
    //
    //    if(dispatch_get_current_queue() == dispatch_get_main_queue())
    //        block();
    //    else
    //        dispatch_async(dispatch_get_main_queue(), block);
    
}


//为所有好友设置头像
-(void)setFriendsHeadImage
{
    [self setMyselfImage];
    for (NSString *user in self.roster) {
        NSRange range = [user rangeOfString:@"@"];
        XMPPJID *userJID;
        if (range.location == NSNotFound) {
            //不包含
            NSLog(@"%@",user);
            userJID = [XMPPJID jidWithUser:user domain:kHOSTNAME resource:@"xmpp"];
        }else{
            //包含
            NSString *tempUser = [user substringToIndex:range.location];
            userJID = [XMPPJID jidWithUser:tempUser domain:kHOSTNAME resource:@"xmpp"];
        }
        NSLog(@"%@",userJID);
        //        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:userJID xmppStream:xmppStream managedObjectContext:managedObjectContext_roster];
        [self setUserImage:userJID];
    }
}

//头像改变
-(void)headImageChanged
{
    [self setFriendsHeadImage];
}



//注册
- (void)registerInSide:(NSString *)userName andPassword:(NSString *)thePassword{
    isRegister = YES;
    NSError *err;
    NSString *tjid = [[NSString alloc] initWithFormat:@"%@@%@",userName,kDOMAIN];  //smack
    password = thePassword;
    XMPPJID *jid = [XMPPJID jidWithString:tjid resource:@"DianDianer"];
    [xmppStream setMyJID:jid];
   
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接服务器失败" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
    }
}

-(void)_registerNow
{
    NSError *err;
    if (![xmppStream registerWithPassword:password error:&err]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }else
    {
        NSLog(@"成功注册啦");
    }
    
}

- (IBAction)addNewFriend:(NSString*)newFriendName {
    
    XMPPJID *jid = [XMPPJID jidWithUser:newFriendName domain:kHOSTNAME resource:@"xmpp"];
	
	[[self xmppRoster] addUser:jid withNickname:newFriendName];
	
	// Clear buddy text field
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Send Messager
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)uploadAudio:(id)sender {
    //ca9f3948472ebbe940fbc16f76bccb95
    //    NSURL *recordedFile = [NSURL URLWithString:[[NSBundle mainBundle]pathForResource:@"endgame" ofType:@"wav"]];
    NSData * soundData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"msg" ofType:@"amr"]];
    NSLog(@"%d",soundData.length);
    NSString *sound=[soundData base64EncodedString];
    NSLog(@"%d",sound.length);
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/msg.amr"];
    NSError *error = nil;
    BOOL write = [sound writeToFile:path atomically:YES encoding: NSUTF8StringEncoding error:&error];
    if (write) {
        NSLog(@"yes");
    }else{
        NSLog(@"no %@",error.description);
    }
    //    NSLog(@"%@",sound);
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    // [body setStringValue:@"image"];
    
    NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment"];
    [attachment setStringValue:sound];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",@"tosomeone",kDOMAINWITHSOURCE]];
    [message addChild:body];
    [message addChild:attachment];
    [self.xmppStream sendElement:message];
    //    UIImage *selectedImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"camer" ofType:@"png"]];
    //    NSData *dataObjww = UIImageJPEGRepresentation(selectedImage,0);
    //
    //    NSString *strMessage;
    //
    //    strMessage = [dataObjww base64EncodedString];
    
    
    //    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    //    [body setStringValue:@"image"];
    //
    //    NSXMLElement *attachment = [NSXMLElement elementWithName:@"attachment"];
    //    [attachment setStringValue:strMessage];
    //
    //    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    //    [message addAttributeWithName:@"type" stringValue:@"chat"];
    //    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@saas.kanyabao.com",self.toTextField.text]];
    //    [message addChild:body];
    //    [message addChild:attachment];
    //    [self.xmppStream sendElement:message];
    
    NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
    [xmlBody setStringValue:sound];
    NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",self.toSomeOne,kDOMAIN]];
    [xmlMessage addChild:xmlBody];
    [self.xmppStream sendElement:xmlMessage];
    
}

//播放声音
- (IBAction)play:(id)sender {
    //    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/test.wav", strUrl]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/test.amr"];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    self.avPlay = player;
    [self.avPlay play];
}

//打印聊天列表
- (void)printCoreData:(id)sender {
    NSManagedObjectContext *context = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    [self print:[[NSMutableArray alloc]initWithArray:messages]];
}
-(void)print:(NSMutableArray*)messages{
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
            NSLog(@"messageStr param is %@",message.messageStr);
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
            NSLog(@"NSCore object id param is %@",message.objectID);
            NSLog(@"bareJid param is %@",message.bareJid);
            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
            NSLog(@"timestamp param is %@",message.timestamp);
            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
            NSLog(@"streamBareJidStr is %@",message.streamBareJidStr);
            NSLog(@"thread is %@",message.thread);
        }
    }
}

- (void)saveHistory:(XMPPMessage *)message {
    NSManagedObjectContext *context = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
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
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    NSLog(@"%@",myJID);
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	myJID = [NSString stringWithFormat:@"%@@%@",myJID,kDOMAIN];
    //    myPassword = self.passwordTextField.text;
	
    XMPPJID *jid = [XMPPJID jidWithString:myJID resource:@"DianDianer"];
	[xmppStream setMyJID:jid];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        NSLog(@"%@",@"error connecting");
        
		return NO;
	}
    
    
    
    //验证成功更新聊天列表
    //    [chartListsForCurrentUser removeAllObjects];
    chartListsForCurrentUser = [[DiandianCoreDataManager shareDiandianCoreDataManager]allChartListWithRecentMessagesForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
    
    
    return YES;
    
}

- (void)disconnect
{
    [self.roster removeAllObjects];
	[self goOffline];
	[xmppStream disconnect];
}
- (void)teardownStream
{
    [self.roster removeAllObjects];
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
    
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
    [xmppSearch            deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

//验证用户
-(BOOL)authenticate
{
    if ([xmppStream isDisconnected]) {
        NSLog(@"未连接成功！！");
        return NO;
    }
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    NSLog(@"%@",myJID);
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    myJID = [NSString stringWithFormat:@"%@@%@",myJID,kDOMAIN];
    
    
    XMPPJID *jid = [XMPPJID jidWithString:myJID resource:@"DianDianer"];
    [xmppStream setMyJID:jid];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream authenticateWithPassword:password error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        NSLog(@"%@",@"error authenticate!1");
        
        return NO;
    }
    return YES;
    
    
}
#pragma mark XMPPvCardTempModuleDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceivevCardTemp" object:nil userInfo:[NSDictionary dictionaryWithObject:vCardTemp forKey:@"vCardTemp"]];
    
    
    NSLog(@"Ohoo,I get the message");
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - button tapped methods
- (IBAction)sendAttechment:(id)sender {
    NSXMLElement *value1 = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/bytestreams"];
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/ibb"];
    NSXMLElement *option1 = [NSXMLElement elementWithName:@"option"];
    [option1 addChild:value1];
    NSXMLElement *option2 = [NSXMLElement elementWithName:@"option"];
    [option2 addChild:value2];
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"stream-method"];
    [field addAttributeWithName:@"type" stringValue:@"list-single"];
    [field addChild:option1];
    [field addChild:option2];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"form"];
    [x addChild:field];
    NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    [feature addChild:x];
    NSXMLElement *desc = [NSXMLElement elementWithName:@"desc" stringValue:@"send"];
    NSXMLElement *file = [NSXMLElement elementWithName:@"file" xmlns:@"http://jabber.org/protocol/si/profile/file-transfer"];
    [file addAttributeWithName:@"name" stringValue:@"camer.tex"];
    [file addAttributeWithName:@"size" stringValue:@"888"];
    [file addChild:desc];
    NSXMLElement *si = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    [si addAttributeWithName:@"profile" stringValue:@"http://jabber.org/protocol/si/profile/file-transfer"];
    [si addAttributeWithName:@"mime-type" stringValue:@"text/plain"];
    [si addAttributeWithName:@"id" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
    [si addChild:feature];
    [si addChild:file];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",@"tosomeon",kDOMAIN]];//
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",@"fromsomeone",kDOMAIN]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"iq_13"];
    [iq addChild:si];
    [self.xmppStream sendElement:iq];
    
    
}

- (IBAction)connectXMPP:(id)sender {
    [self connect];
}

- (void)sendMessage:(id)sender {
    NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
    [xmlBody setStringValue:@"messages"];
    NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",self.toSomeOne,kDOMAIN]];
    [xmlMessage addChild:xmlBody];
    [self.xmppStream sendElement:xmlMessage];
    
    //    [XMPPManager instence].toSomeOne = self.toTextField.text;
    //    NSMutableDictionary *msgAsDictionary = [[NSMutableDictionary alloc] init];
    //    [msgAsDictionary setObject:self.messageTextField.text forKey:@"message"];
    //    [msgAsDictionary setObject:@"you" forKey:@"sender"];
    //    [self.messages addObject:msgAsDictionary];
    NSLog(@"From: You, Message: %@", @"messages");
    
}

-(void)sendMyMessage:(NSXMLElement *)message
{
    
    [self.xmppStream sendElement:message];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	 managedObjectContext_roster = [xmppRosterStorage mainThreadManagedObjectContext];
	if (managedObjectContext_roster == nil)
	{
		managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_roster;
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	managedObjectContext_capabilities = [xmppCapabilitiesStorage mainThreadManagedObjectContext];
	if (managedObjectContext_capabilities == nil)
	{
		managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_capabilities;
}

- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
		});
    }
	
	if (sender != managedObjectContext_capabilities &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_capabilities", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
		});
	}
}

- (NSManagedObjectContext *)managedObjectContext_messageArchiving
{
    managedObjectContext_messageArchiving = [xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    return managedObjectContext_messageArchiving;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPROSTER Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)XMPPRosterFetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
        //按状态分组和按名字排序
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        
        //添加按条件查询 剔除自己
        NSString *JID = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
        JID = [JID stringByAppendingFormat:@"@%@",kDOMAIN];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jidStr != %@",JID];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:predicate];
        //		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
            			DDLogError(@"Error performing fetch: %@", error);
//            NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSFetchedResultsController Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

    if (controller == fetchedResultsController) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(controllerDidChangedWithFetchedResult:)]) {
            [self.delegate controllerDidChangedWithFetchedResult:controller];
        }
    }
    
    if (controller == fetchedMessageArchivingResultsController) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(controllerDidChangedWithFetchedMessageArchingResult:)]) {
            [self.delegate controllerDidChangedWithFetchedMessageArchingResult:controller];
        }
        
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMPPMessage Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//查询消息记录
- (NSFetchedResultsController *)XMPPMessageArchivingFetchedResultsController
{
    if (fetchedMessageArchivingResultsController == nil) {
        NSManagedObjectContext *moc = [self managedObjectContext_messageArchiving];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:moc];
        //添加按条件查询
        NSString *JID = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
        JID = [JID stringByAppendingFormat:@"@%@",kDOMAIN];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",JID,self.toSomeOne];
        //按时间 和 好友排序
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc]initWithKey:@"bareJidStr" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedMessageArchivingResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"bareJidStr" cacheName:@"fetchedMessages"];

        [fetchedMessageArchivingResultsController setDelegate:self];
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            DDLogError(@"Error performing fetch:%@",error);
        }
        
    }
    return fetchedMessageArchivingResultsController;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //    registerSuccess = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号成功" message:@"创建成功！" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [self.delegate leaveRegister];
    
    isXmppConnected = NO;
    [xmppStream disconnect];
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败" message:@"用户名冲突" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"socketDidConnect");
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    NSLog(@"willSecureWithSettings");
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidSecure");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
	isXmppConnected = YES;
	
	NSError *error = nil;
    if (isRegister) {
        [self _registerNow];
        isRegister = !isRegister;
        return;
    }
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
        NSLog(@"Error authenticating: %@", error);
	}
    
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"xmppStreamDidAuthenticate");
    if (![xmppStream.myJID.user isEqualToString:@"guest"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(authenticateSuccessed)]) {
            [self.delegate authenticateSuccessed];
        }
        
    }
    
	[self goOnline];
    
    
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate : %@",error);
    if (![xmppStream.myJID.user isEqualToString:@"guest"]) {
        [self.delegate authenticateFailed];
    }
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSLog(@"didSendIQ ----------%@",iq.description);
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"didReceiveIQ :++++++++++ %@",iq.description);
    //  #if !TARGET_IPHONE_SIMULATOR
    //	{
    //        NSMutableString *senderJID = [[NSMutableString alloc]init];
    //        NSMutableString *recieverJID = [[NSMutableString alloc] init];
    //
    //        if ([TURNSocket isNewStartTURNRequest:iq]) {
    //            NSLog(@"IS NEW TURN request Receive.. TURNSocket..................");
    //            TURNSocket *aturnSocket = [[TURNSocket alloc] initWithStream:xmppStream incomingTURNRequest:iq];
    //            [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:@"saas.kanyabao.coms", nil]];//,@"proxy.saas.kanyabao.com",@"123.126.92.67"
    //            [aturnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //        }
    //
    //        if ([self isSetAskToTransfer:iq sender:senderJID reciever:recieverJID])[self sendAcceptIQRe:senderJID];
    //        return YES;
    //	}
    //#endif
    //    [self isResultAcceptOK:iq];
    
    
    //    [self getVisibleProxyAndSendToProxyToGetHost:iq];
    //    [self getHostAndPort:iq AndSend:senderJID ToReciever:recieverJID];
    //    [self getStreamhostUsedAndActivate:iq];
    //    [self.roster removeAllObjects];
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                NSString *jid = [item attributeStringValueForName:@"jid"];
                //                XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
                
                if (![self.roster containsObject:jid]) {
                    [self.roster addObject:jid];
                }
                
            }
        }
    }
    NSLog(@"%@",self.roster);
    //尝试将好友写入本地数据库
    NSLog(@"%@",xmppStream.myJID);
    
//    //代理  刷新好友列表
//    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableView)]) {
//        [self.delegate reloadTableView];
//    }
//    //将好友列表写入数据库
    [[DiandianCoreDataManager shareDiandianCoreDataManager]addChartListFromFriends:self.roster];
    
    
	return YES;
}
//====================================================================================================================
- (BOOL)isSetAskToTransfer:(XMPPIQ *)iq sender:(NSMutableString *)senderJID reciever:(NSMutableString *)recieverJID{
    if ([iq isSetIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([element.name isEqualToString:@"si"]) {
            [senderJID setString:iq.fromStr];
            [recieverJID setString:iq.toStr];
            
            return YES;
        }
    }
    return NO;
}
- (void)sendAcceptIQRe:(NSString *)reciever{
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    [value setStringValue:@"http://jabber.org/protocol/bytestreams"];
    NSXMLElement *value2 = [NSXMLElement elementWithName:@"value"];
    [value2 setStringValue:@"http://jabber.org/protocol/ibb"];
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"stream-method"];
    [field addChild:value];
    [field addChild:value2];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    [x addChild:field];
    NSXMLElement *feature = [NSXMLElement elementWithName:@"feature" xmlns:@"http://jabber.org/protocol/feature-neg"];
    [feature addChild:x];
    NSXMLElement *si = [NSXMLElement elementWithName:@"si" xmlns:@"http://jabber.org/protocol/si"];
    [si addChild:feature];
    NSXMLElement *sendIQ = [NSXMLElement elementWithName:@"iq"];
    [sendIQ addAttributeWithName:@"type" stringValue:@"result"];
    [sendIQ addAttributeWithName:@"to" stringValue:reciever];
    [sendIQ addChild:si];
    [self.xmppStream sendElement:sendIQ];
}
- (BOOL)isResultAcceptOK:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"si" isEqualToString:element.name]) {
            if (element.children.count>0) {
                NSXMLElement *feature = [element.children objectAtIndex:0];
                if (feature.children.count>0) {
                    NSXMLElement *x = [feature.children objectAtIndex:0];
                    if ([x.name isEqualToString:@"x"]) {
                        NSDictionary *dic = x.attributesAsDictionary;
                        if ([[dic objectForKey:@"type"] isEqualToString:@"submit"]) {
                            //receiver say ok
                            //进入XEP-0065协议阶段
                            //初始方给服务器发送信息，请求提供代理服务器
                            
                            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/XMPP",self.toSomeOne,kDOMAIN]];
                            [TURNSocket setProxyCandidates:[NSArray arrayWithObjects:@"124.205.147.26", nil]];
                            turnSocket = [[TURNSocket alloc] initWithStream:xmppStream toJID:jid];
                            [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                            
                            //                            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
                            //                            NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                            //                            [iq addAttributeWithName:@"id" stringValue:@"iq_15"];
                            //                            [iq addAttributeWithName:@"type" stringValue:@"get"];
                            //                            [iq addChild:query];
                            //                            [self.xmppStream sendElement:iq];
                        }
                    }
                }
            }
        }
    }
    return NO;
}
- (void)getVisibleProxyAndSendToProxyToGetHost:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"item"]) {
                    NSString *name = [item attributeStringValueForName:@"name"];
                    if ([name isEqualToString:@"Socks 5 Bytestreams Proxy"]) {
                        //初始方给这个代理发送信息获取代理连接信息
                        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
                        NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                        [iq addAttributeWithName:@"id" stringValue:@"iq_19"];
                        [iq addAttributeWithName:@"to" stringValue:[item attributeStringValueForName:@"jid"]];
                        [iq addAttributeWithName:@"type" stringValue:@"get"];
                        [iq addChild:query];
                        [self.xmppStream sendElement:iq];
                    }
                }
            }
        }
    }
}
- (void)getHostAndPort:(XMPPIQ *)iq AndSend:(NSString *)sender ToReciever:(NSString *)reciever{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSString *host ;
            NSString *port ;
            NSString *pjid;
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"streamhost"]) {
                    host = [item attributeStringValueForName:@"host"];
                    port = [item attributeStringValueForName:@"port"];
                    pjid = [item attributeStringValueForName:@"jid"];
                    proxyPort = port;
                    proxyHost = host;
                    proxyJID = pjid;
                    //初始方收到代理信息后将代理的信息发送给目标方
                    NSXMLElement *streamhost = [NSXMLElement elementWithName:@"streamhost"];
                    [streamhost addAttributeWithName:@"port" stringValue:port];
                    [streamhost addAttributeWithName:@"host" stringValue:@"124.205.147.26"];//123.126.92.67
                    [streamhost addAttributeWithName:@"jid" stringValue:host];
                    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
                    [query addAttributeWithName:@"mode" stringValue:@"tcp"];
                    [query addAttributeWithName:@"sid" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
                    [query addChild:streamhost];
                    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
                    [iq addAttributeWithName:@"to" stringValue:@"wangdf@saas.kanyabao.com/Spark 2.6.3"];
                    [iq addAttributeWithName:@"type" stringValue:@"set"];
                    [iq addAttributeWithName:@"id" stringValue:@"iq_19"];
                    [iq addAttributeWithName:@"from" stringValue:@"abc@saas.kanyabao.com/XMPP"];
                    [iq addChild:query];
                    [self.xmppStream sendElement:iq];
                }
                
            }
        }
    }
}
- (void)getStreamhostUsedAndActivate:(XMPPIQ *)iq{
    if ([iq isResultIQ]) {
        NSXMLElement *element = iq.childElement;
        if ([@"query" isEqualToString:element.name]) {
            NSArray *items = [element children];
            for (NSXMLElement *item in items) {
                if ([item.name isEqualToString:@"streamhost-used"]) {
                    //                    NSString *streamhostused = [item attributeStringValueForName:@"jid"];
                    NSError *error ;
                    
                    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                    //                    [self.xmppStream connectP2PWithSocket:socket error:&error];
                    //                    NSLog(@"error : %@",error);
                    if ([socket connectToHost:@"124.205.147.26" onPort:5222 error:&error]) {
                    }else{
                        if (error) {
                            NSLog(@"socke error : %@",error);
                        }
                    }
                }
            }
        }
    }
}
//=======================================================================================================================

//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
//{
//
//    NSLog(@"didConnectToHost : %@ :%d",host,port);
//
////    int a[3] = {5,1,0};
////    NSData *data = [[NSData alloc] initWithBytes:a length:3];
////    NSLog(@"data; %@",data);
//    [sock writeData:[@"5,1,0" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [sock readDataWithTimeout:-1 tag:0];
//
////    NSXMLElement *activate = [NSXMLElement elementWithName:@"activate" stringValue:@"wangdf@saas.kanyabao.com/Spark 2.6.3"];
////    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/bytestreams"];
////    [query addAttributeWithName:@"sid" stringValue:@"82B0C697-C1DE-93F9-103E-481C8E7A3BD8"];
////    [query addChild:activate];
////    NSXMLElement *iqsend = [NSXMLElement elementWithName:@"iq"];
////    [iqsend addAttributeWithName:@"to" stringValue:@"proxy.saas.kanyabao.com"];
////    [iqsend addAttributeWithName:@"type" stringValue:@"set"];
////    [iqsend addAttributeWithName:@"id" stringValue:@"iq_21"];
////    [iqsend addAttributeWithName:@"from" stringValue:@"abc@saas.kanyabao.com/XMPP"];
////    [iqsend addChild:query];
////    [self.xmppStream sendElement:iqsend];
//
//
//}
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//{
//    NSLog(@"didWriteDataWithTag");
////    [sock readDataWithTimeout:30 tag:0];
////    NSData *data = [[NSData alloc]init];
////    NSMutableData *mData = [[NSMutableData alloc]init];
////    [sock readDataToData:data withTimeout:30 buffer:mData bufferOffset:5 tag:0];
////    [sock readDataWithTimeout:30 buffer:mData bufferOffset:5 tag:0];
//
//}
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    NSLog(@"didReadData : %@",data);
//}
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//{
//    NSLog(@"socketDidDisconnect error : %@",err);
//
//
//}
//=======================================================================================================================
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"did send message : %@",message.description);
    [self saveHistory:message];
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"didReceiveMessage ： %@",message.description);
	// A simple example of inbound message handling.
    
    //    [self.delegate showMessage:message];
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *displayName = [user displayName];
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
            if (![[Singleton instance]isCharting]) {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.alertAction = @"Ok";
                localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            }
            
            
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
       NSLog(@"didReceivePresence : %@",presence.description);
    //    if (![presence.type isEqualToString:@"error"]) {
    //        self.jidWithResouce = presence.fromStr;
    //    }
    //    NSLog(@"jidWithResouce : %@",jidWithResouce);
    
}

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"didReceiveSubsriptionRequest : %@",presence.description);
    if ([presence.type isEqualToString:@"subscribe"]) {
        NSString *message = [NSString stringWithFormat:@"%@想要添加你为好友！",presence.fromStr];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
            alertView.tag = tag_subcribe_alertView;
            [alertView show];
        }else{
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"OK";
            localNotification.alertBody = message;
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber += 1;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

        }

    }
}



-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    NSLog(@"%@",item);
}

//- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
//{
//    NSLog(@"%@",[presence description]);
//    
//}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"didReceiveError");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect");
	if (!isXmppConnected)
	{
        NSLog(@"Unable to connect to server. Check xmppStream.hostName");
	}
}
//- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
//{
//    NSLog(@"alternativeResourceForConflictingResource : %@",conflictingResource);
//    return @"XMPP";
//}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	NSLog(@"%@",displayName);
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}
-(void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    NSLog(@"users: %@", [sender unsortedUsers]);
    // My subscribed users do print out
}
#pragma mark -
#define tag_writeData 1000
#define tag_readData 1001
- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket
{
    NSLog(@"TURNSocket   didSucceed");
    mySocket = socket;
    [mySocket setDelegate:self delegateQueue:dispatch_get_main_queue()];
#if !TARGET_IPHONE_SIMULATOR
	{
        NSData *dataF = [[NSData alloc] init];
        [socket readDataToData:dataF withTimeout:-1.0 tag:tag_readData];
        NSLog(@"dataF: %d", [dataF length]);
        return;
    }
#endif
    [socket writeData:[@"hello" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:tag_writeData];//[NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"camer" ofType:@"png"]]
    [socket readDataWithTimeout:-1 tag:tag_readData];
    [socket disconnectAfterWriting];
    
    
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag tag ; %ld",tag);
    //    [sock readDataWithTimeout:-1 tag:1001];
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData data : %@",data);
    
}
- (void)turnSocketDidFail:(TURNSocket *)sender
{
    NSLog(@"turnSocketDidFail-----%@",sender.description);
    
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
    if (alertView.tag == tag_subcribe_alertView && buttonIndex == 1) {
        
        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }else{
        [[self xmppRoster] rejectPresenceSubscriptionRequestFrom:jid];
    }
}
#pragma mark - my method
-(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}




#pragma mark - ChartList Method
-(NSArray *)startLoadMessages:(NSString *)toJid
{
    NSString *currentCLTitle = [NSString stringWithFormat:@"%@+%@",[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID],toJid];
    NSLog(@"%@",currentCLTitle);
    //所有消息
    NSArray *currentCL;
    //获得当前的聊天记录
    chartListsForCurrentUser = [[DiandianCoreDataManager shareDiandianCoreDataManager]allChartListWithRecentMessagesForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
    for (ChartList *aChartList in chartListsForCurrentUser) {
        if ([aChartList.chartList_id isEqualToString:currentCLTitle]) {
            currentCL = [NSArray arrayWithArray:[aChartList.chartListToMessages array]];
            break;
        }
    }
    
    NSInteger stopIndex = currentCL.count;
    NSArray *resultArr;
    if (stopIndex < kMessageStep) {
        if (stopIndex > 0) {
            resultArr = [currentCL subarrayWithRange:NSMakeRange(0, stopIndex)];
        }
        
    }else
    {
        resultArr = [currentCL subarrayWithRange:NSMakeRange(stopIndex  - kMessageStep , kMessageStep)];
    }
    
    return resultArr;
}

//获得更多聊天记录
-(NSArray *)loadMoreMessages:(NSInteger)currentMessagesCount andToJid:(NSString *)toJid
{
    //聊天记录名
    NSString *currentCLTitle = [NSString stringWithFormat:@"%@+%@",[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID],toJid];
    //所有消息
    NSArray *currentCL;
    //获得当前的聊天记录
    chartListsForCurrentUser = [[DiandianCoreDataManager shareDiandianCoreDataManager]allChartListWithRecentMessagesForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
    for (ChartList *aChartList in chartListsForCurrentUser) {
        if ([aChartList.chartList_id isEqualToString:currentCLTitle]) {
            currentCL = [NSArray arrayWithArray:[aChartList.chartListToMessages array]];
            break;
        }
    }
    NSInteger totalNum = currentCL.count;
    NSInteger currentNum = currentMessagesCount;
    NSArray *resultArr;
    if ((totalNum - currentNum) < kMessageStep) {
        resultArr = currentCL;
    }else{
        resultArr = [currentCL subarrayWithRange:NSMakeRange(totalNum - currentNum - kMessageStep, kMessageStep + currentNum)];
    }
    return resultArr;
}



@end
