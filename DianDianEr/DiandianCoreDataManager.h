//
//  DiandianCoreDataManager.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Share.h"
#import "ChartList.h"
#import "Comment.h"
#import "Reply.h"
#import "Good.h"
#import "Messages.h"

@protocol DiandianCoreDataManagerDelegate <NSObject>

- (void)parameterShare:(Share *)share;
- (void)parameterComment:(Comment *)comment;
- (void)parameterReply:(Reply *)comment;
- (void)parameterGood:(Good *)comment;

@end

@interface DiandianCoreDataManager : NSObject
{
    
}

@property (assign, nonatomic) id<DiandianCoreDataManagerDelegate> delegate;

@property (strong, nonatomic) Share *   aShare;
@property (strong, nonatomic) Comment   *aComment;
@property (strong, nonatomic) Reply     *aReply;
@property (strong, nonatomic) Good      *aGood;
@property (strong, nonatomic) ChartList *aChartList;
@property (strong, nonatomic) Messages  *aMessage;

/*---------------------------------------------------------------------------
     聊天     聊天     聊天     聊天     聊天     聊天     聊天     聊天     聊天
 ----------------------------------------------------------------------------*/
//聊天列表
@property (strong, nonatomic) NSArray *allChartList;

+ (DiandianCoreDataManager *)shareDiandianCoreDataManager;
- (id)init;

- (Share *)createShare;
- (Share *)create_locality_share;
- (NSArray *)all_share;
- (void)insert_a_share:(NSManagedObject *)object;
- (void)delete_a_share:(NSManagedObject *)object;

/*---------------------------------------------------------------------------
                分享   分享   分享   分享   分享   分享   分享   分享   分享
 ----------------------------------------------------------------------------*/

//写入数据库一条分享及其它的评论回复
-(Share *)createAShare:(NSDictionary *)shareDic;
//所有的分享ID
-(NSArray *)_allShareID;
//所有的评论ID
-(NSArray *)_allCommentID;
//所有的回复ID
-(NSArray *)_allReplyID;

-(NSArray *)myShare;
-(NSArray *)imageShare;
-(NSArray *)soundShare;
-(NSArray *)textShare;
//分享的代理方法，写入本地数据库成功之后，触发该方法，上传网络数据库
-(void)updateShare;

//评论
- (Comment *)creatComment;
- (NSArray *)allComment;
- (Comment *)create_locality_comment;

//回复
- (Reply *)creatReply;
- (NSArray *)allReply;
- (Reply *)create_locality_reply;

//赞
- (Good *)creatGood;
- (NSArray *)allGood;
- (Good *)create_locality_Good;

//聊天列表方法
//通过消息获得聊天列表名字
-(NSString *)getChartListIDForMessage:(Messages *)message;

//创建一条消息
-(Messages *)createAMessage;

//用户最近的所有聊天列表
-(NSArray *)allChartListWithRecentMessagesForUser:(NSString*)jid;
//向聊天列表中添加消息
-(BOOL)addMessage:(Messages *)nMessage intoChartLists:(NSMutableArray *)ChartLists;
//更新聊天列表
-(BOOL)upDataChartList:(ChartList *)chartList;

//某一聊天记录的所有消息
-(NSArray *)allMessages:(ChartList *)chartList;

//添加某一用户好友列表
-(BOOL)addChartListFromFriends:(NSArray *)friendList;

@end



