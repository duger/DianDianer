//
//  XMPPManager.h
//  DianDianEr
//
//  Created by Duger on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "TURNSocket.h"
#import "TURNSocket.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@protocol XMPPManagerDelegate <NSObject>
@optional
-(void)reloadTableView;
-(void)authenticateSuccessed;
-(void)authenticateFailed;
-(void)leaveRegister;

@end

@interface XMPPManager : NSObject<XMPPRosterDelegate,XMPPvCardTempModuleDelegate>
{
	XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

	TURNSocket * turnSocket;
	NSString *password;
    XMPPSearch *xmppSearch;
    NSManagedObjectContext *managedObjectContext_roster;
	NSManagedObjectContext *managedObjectContext_capabilities;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
    BOOL isRegister;
    NSString *jidWithResouce;
    NSString *proxyHost;
    NSString *proxyPort;
    NSString *proxyJID;
    GCDAsyncSocket *mySocket;
    AVAudioRecorder *recorder;
    NSURL *urlPlay;
    
}
///单例
+(XMPPManager *)instence;
//聊天记录
@property (nonatomic, retain) NSArray *chartListsForCurrentUser;
@property(retain,nonatomic) NSMutableArray *roster;
@property (nonatomic,retain) NSString *toSomeOne;
@property(nonatomic ,retain) NSMutableDictionary *headImages;
//好友列表
@property(nonatomic,retain) NSMutableArray *friendList;
//@property(nonatomic,assign) id<XMPPViewControllerDelegate> delegate;

//获得聊天记录
-(NSArray *)startLoadMessages:(NSString *)toJid;
//获得更多聊天记录
-(NSArray *)loadMoreMessages:(NSInteger)currentMessagesCount andToJid:(NSString *)toJid;
//聊天记录xmpp版
- (void)saveHistory:(XMPPMessage *)message;
//为所有好友设置头像
-(void)setFriendsHeadImage;

@property (retain, nonatomic) AVAudioPlayer *avPlay;

//-----------------------------------------------------------------------------------------
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) TURNSocket *turnSocket;
@property (nonatomic,strong) NSString *jidWithResouce;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;
- (void)setupStream;
- (void)teardownStream;
- (void)goOnline;
- (void)goOffline;
-(BOOL)authenticate;
//------------------------------------------------------------------------------------------

@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;

//-----------------------------------------------------------------------------------------
@property (strong, nonatomic) IBOutlet UITextField *hostTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *toTextField;
@property (strong, nonatomic) IBOutlet UITextField *addFriendTextField;
@property (strong, nonatomic) IBOutlet UITextView *informationTextView;
- (IBAction)sendAttechment:(id)sender;
- (IBAction)connectXMPP:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)registerInSide:(NSString *)userName andPassword:(NSString *)thePassword;
- (IBAction)addNewFriend:(NSString*)newFriendName;
- (IBAction)uploadAudio:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)printCoreData:(id)sender;


//------------------------------------------------------------------------------------------
///my method
-(void)showAlertView:(NSString *)message;

@property (nonatomic,assign) id<XMPPManagerDelegate> delegate;

@end


