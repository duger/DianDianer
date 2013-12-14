//
//  DiandianCoreDataManager.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "DiandianCoreDataManager.h"
#import "ShareViewController.h"


@interface DiandianCoreDataManager ()

-(NSManagedObjectContext *)context;
-(NSPersistentStoreCoordinator *)coordinator;
-(NSManagedObjectModel *)modle;

@end

static DiandianCoreDataManager *aDiandianCoreDataManager = nil;
@implementation DiandianCoreDataManager
{
    NSManagedObjectContext                  *context;
    NSPersistentStoreCoordinator            *coordinator;
    NSManagedObjectModel                    *model;
    
}

@synthesize delegate;
@synthesize aShare;
@synthesize aComment;
@synthesize aReply;
@synthesize aGood;
@synthesize aChartList;
@synthesize aMessage;
@synthesize allChartList;

+(DiandianCoreDataManager *)shareDiandianCoreDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (aDiandianCoreDataManager == nil){
            aDiandianCoreDataManager = [[DiandianCoreDataManager alloc] init];
        }
        
    });
    return aDiandianCoreDataManager;
}
- (id)init
{
    self = [super init];
    if (self) {
        [self context];
    }
    return self;
}


//格式化时间输出样式
static inline NSString * dateFormatter(NSDate *aDate)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *str =  [dateFormatter stringFromDate:aDate];
    return str;
}
//文件路径
-(NSString *)getPath
{
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * filePath = [documentPath stringByAppendingFormat:@"/Share.sqlite"];
    return filePath;
}
#pragma mark - 管理器 - 连接器 - 模型器
-(NSManagedObjectContext *)context
{
    if (context != nil ) {
        return context;
    }
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:[self coordinator]];
    return context;
}

-(NSPersistentStoreCoordinator *)coordinator
{
    if (coordinator != nil ) {
        return coordinator;
    }
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self modle]];
    
    NSURL *url = [NSURL fileURLWithPath:[self getPath]];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setValue:@(YES) forKey:NSAddedPersistentStoresKey];
    NSError * error = nil;
    //删除日志
    [options setObject:@{@"journal_mode":@"DELETE"} forKey:NSSQLitePragmasOption];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
    if (error) {
        //如果连接错误
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据库连接失败" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Back",error,nil];
        [alertView show];
    }
    return coordinator;
}

-(NSManagedObjectModel *)modle
{
    if (model != nil ) {
        return model;
    }
    model = [NSManagedObjectModel mergedModelFromBundles:nil];
    return model;
}


#pragma 分享
- (void)save
{
    if ([[self context] hasChanges]) {
        [[self context] save:nil];
    }
}
//创建分享（把本地分享数据写入服务器）
- (Share *)createShare
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Share" inManagedObjectContext:[self context]];
    aShare = [[Share alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self.delegate parameterShare:aShare];
    [self save];
    return aShare;
    
}

//写入数据库一条分享及其它的评论回复
-(Share *)createAShare:(NSDictionary *)shareDic
{
    //格式化时间样式
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *shareID = [shareDic objectForKey:@"share_id"];
    NSLog(@"%@",[shareDic description]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Share"];
    request.predicate = [NSPredicate predicateWithFormat:@"s_id==%@",shareID];
    
    
    
    NSError *error;
    NSArray *resultArr = [self.context executeFetchRequest:request error:&error];
    if (![self.context countForFetchRequest:request error:nil]) {
        Share *share = [[Share alloc]initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
        
        
        //写入分享
        share.s_content = [shareDic objectForKey:@"share_content"];
        share.s_createdate = [format dateFromString:[shareDic objectForKey:@"share_createdate"]];
        share.s_hot = [NSNumber numberWithInt:(int)[shareDic objectForKey:@"share_hot"]];
        share.s_id = [NSString stringWithFormat:@"%@",[shareDic objectForKey:@"share_id"]];
        share.s_image_url = [shareDic objectForKey:@"share_image_url"];
        share.s_sound_url = [shareDic objectForKey:@"share_sound_url"];
        share.s_latitude = [NSNumber numberWithDouble:[[shareDic objectForKey:@"share_latitude"]doubleValue]];
        share.s_longitude = [NSNumber numberWithDouble:[[shareDic objectForKey:@"share_longtitude"]doubleValue]];
        share.s_locationName = [shareDic objectForKey:@"share_locationName"];
        share.s_user_id = [shareDic objectForKey:@"share_user_id"];
        
        NSLog(@"%@",[shareDic objectForKey:@"comment_id"]);
        if ([shareDic objectForKey:@"comment_id"] != [NSNull null]) {
            //写入评论
            Comment *theComment = [[Comment alloc]initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
            
            theComment.c_content = [shareDic objectForKey:@"comment_content"];
            theComment.c_date = [format dateFromString:[shareDic objectForKey:@"comment_date"]];
            theComment.c_id = [shareDic objectForKey:@"comment_id"];
            theComment.c_user_id = [shareDic objectForKey:@"comment_user_id"];
            theComment.share_id = [NSString stringWithFormat:@"%@",[shareDic objectForKey:@"share_id"]];
            [share addShareToCommentObject:theComment];
            
            NSLog(@"%@",[shareDic objectForKey:@"reply_id"]);
            if ([shareDic objectForKey:@"reply_id"] != [NSNull null]) {
                //写入回复
                Reply *theReply = [[Reply alloc]initWithEntity:[NSEntityDescription entityForName:@"Reply" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
                theReply.r_content = [shareDic objectForKey:@"reply_content"];
                theReply.r_date = [format dateFromString:[shareDic objectForKey:@"reply_date"]];
                theReply.r_from_id = [shareDic objectForKey:@"reply_from_id"];
                theReply.r_to_id = [shareDic objectForKey:@"reply_to_id"];
                theReply.r_comment_id = [shareDic objectForKey:@"comment_id"];
                theReply.r_id = [shareDic objectForKey:@"reply_id"];
                [theComment addCommentToReplyObject:theReply];
                
            }
        }
        

        [self save];
        
    }else{
        //有相同的分享
        //获得那条分享
        Share *tempshare = [resultArr lastObject];

        NSLog(@"%@",[shareDic objectForKey:@"comment_id"]);
        if ([shareDic objectForKey:@"comment_id"] == [NSNull null]) {
            return tempshare;
        }
        NSString *commentID = [shareDic objectForKey:@"comment_id"];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
        request.predicate = [NSPredicate predicateWithFormat:@"c_id==%@",commentID];
        NSError *error2;
        NSArray *commentArr = [self.context executeFetchRequest:request error:&error2];
        
        NSLog(@"%d",[self.context countForFetchRequest:request error:nil]);
        if (![self.context countForFetchRequest:request error:nil]) {
            Comment *theComment = [[Comment alloc]initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
            
            
            //没有相同的评论
            theComment.c_content = [shareDic objectForKey:@"comment_content"];
            theComment.c_date = [format dateFromString:(NSString*)[shareDic objectForKey:@"comment_date"]];
            theComment.c_id = [shareDic objectForKey:@"comment_id"];
            theComment.c_user_id = [shareDic objectForKey:@"comment_user_id"];
            theComment.share_id = [NSString stringWithFormat:@"%@",[shareDic objectForKey:@"share_id"]];
            [tempshare addShareToCommentObject:theComment];
            
            NSLog(@"%@",[shareDic objectForKey:@"reply_id"]);
            if ([shareDic objectForKey:@"reply_id"] != [NSNull null]) {
                //写入回复
                Reply *theReply = [[Reply alloc]initWithEntity:[NSEntityDescription entityForName:@"Reply" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
                theReply.r_content = [shareDic objectForKey:@"reply_content"];
                theReply.r_date = [format dateFromString:[shareDic objectForKey:@"reply_date"]];
                theReply.r_from_id = [shareDic objectForKey:@"reply_from_id"];
                theReply.r_to_id = [shareDic objectForKey:@"reply_to_id"];
                theReply.r_comment_id = [shareDic objectForKey:@"comment_id"];
                theReply.r_id = [shareDic objectForKey:@"reply_id"];
                [theComment addCommentToReplyObject:theReply];
            }

            [self save];
            
            return tempshare;
        }else{//有相同的评论
                //获得相同的评论
            Comment *tempComment = [commentArr lastObject];
            
            NSLog(@"%@",[shareDic objectForKey:@"reply_id"]);
            if ([shareDic objectForKey:@"reply_id"] != [NSNull null]) {
                Reply *theReply = [[Reply alloc]initWithEntity:[NSEntityDescription entityForName:@"Reply" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
                
                //写入回复
                theReply.r_content = [shareDic objectForKey:@"reply_content"];
                theReply.r_date = [format dateFromString:[shareDic objectForKey:@"reply_date"]];
                theReply.r_from_id = [shareDic objectForKey:@"reply_from_id"];
                theReply.r_to_id = [shareDic objectForKey:@"reply_to_id"];
                theReply.r_comment_id = [NSString stringWithFormat:@"%@",[shareDic objectForKey:@"comment_id"]];
                theReply.r_id = [shareDic objectForKey:@"reply_id"];
                [tempComment addCommentToReplyObject:theReply];
                
                [self save];
                
            }
            
            
        }
        return tempshare;
    }
    return nil;
    
}

//得到所有的分享
- (NSArray *)all_share
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Share"];
    NSArray * result = [[self context] executeFetchRequest:fetchRequest error:nil];
    return result;
}

//插入一条分享
- (void)insert_a_share:(NSManagedObject *)object
{
    [[self context] insertObject:object];
    [self save];
}

//删除一条分享
- (void)delete_a_share:(NSManagedObject *)object
{
    [[self context] deleteObject:object];
    [self save];
    
}

//创建分享（本地）
- (Share *)create_locality_share
{
    //NSString 转换成NSDate
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Share" inManagedObjectContext:[self context]];
    
    aShare = [[Share alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    
    aShare.s_content = [ShareManager defaultManager].shareContents;
    aShare.s_locationName = [ShareManager defaultManager].locationPlace;
    aShare.s_createdate = [date  dateByAddingTimeInterval: interval];
    aShare.s_id = [NSString stringWithFormat:@"%@+%f",[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID],[aShare.s_createdate timeIntervalSince1970]];
    aShare.s_user_id = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    if (![[ShareManager defaultManager].tempImagePath isEqualToString:@""]) {
        aShare.s_image_url = [NSString stringWithFormat:@"http://124.205.147.26/student/class_10/team_seven/resource/images/%@.png",aShare.s_id];
    }
    else
    {
        aShare.s_image_url = @"http://124.205.147.26/student/class_10/team_seven/resource/images";
    }
    if (![[ShareManager defaultManager].inPutSoundsPath isEqualToString:@""]) {
        aShare.s_sound_url = [NSString stringWithFormat:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds/%@.mp3",aShare.s_id];
    }
    else
    {
        aShare.s_sound_url = @"http://124.205.147.26/student/class_10/team_seven/resource/sounds";
    }
    [self save];
    return aShare;
}

//我的分享
- (NSArray *)myShare
{
	NSMutableArray *myShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if ([item.s_user_id isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]]) {
            [myShare addObject: item];
        }
    }
    return myShare;
}

- (NSArray *)imageShare
{
    NSMutableArray *imageArray = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_image_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/images"]) {
            [imageArray addObject:item];
        }
    }
    return imageArray;
}

- (NSArray *)soundShare
{
    NSMutableArray *soundShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_sound_url isEqualToString:@"http://124.205.147.26/student/class_10/team_seven/resource/sounds"]) {
            [soundShare addObject:item];
        }
    }
    return soundShare;
}

- (NSArray *)textShare
{
    NSMutableArray *textShare = [[NSMutableArray alloc]init];
    NSArray *allShare = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in allShare) {
        if (![item.s_content isEqualToString:@""]) {
            [textShare addObject:item];
        }
    }
    return textShare;
}

#pragma mark   评论
//创建 评论
- (Comment *)creatComment
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:[self context]];
    aComment = [[Comment alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self.delegate parameterComment:aComment];
    [self save];
    return aComment;
}
//得到所有的评论
- (NSArray *)allComment
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
    NSArray *result = [[self context] executeFetchRequest:request error:nil];
    return result;
}

//创建 评论（本地）
- (Comment *)create_locality_comment
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:[self context]];
    aComment = [[Comment alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    aComment.c_content = [[ShareManager defaultManager] commentContent];
    aComment.c_date = [[ShareManager defaultManager]creatDate];
    aComment.c_id = [[ShareManager defaultManager] commentID];
    aComment.c_user_id = [[ShareManager defaultManager] userID];
    [self save];
    return aComment;
}

#pragma mark 回复
- (Reply *)creatReply
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reply" inManagedObjectContext:[self context]];
    aReply = [[Reply alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self.delegate parameterReply:aReply];
    [self save];
    return aReply;
}
- (NSArray *)allReply
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Reply"];
    NSArray *result = [[self context] executeFetchRequest:request error:nil];
    return result;
}
- (Reply *)create_locality_reply
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reply" inManagedObjectContext:[self context]];
    
    aReply = [[Reply alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    
    aReply.r_id = [[ShareManager defaultManager] replyID];
    aReply.r_content = [[ShareManager defaultManager] replyContent];
    aReply.r_date = [[ShareManager defaultManager] replyDate];
    aReply.r_to_id = [[ShareManager defaultManager] replyToID];
    aReply.r_from_id = [[ShareManager defaultManager] replyFromID];
    aReply.r_comment_id = [[ShareManager defaultManager] replyCommentID];
    
    [self save];
    return aReply;
}

//赞
- (Good *)creatGood
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Good" inManagedObjectContext:[self context]];
    aGood = [[Good alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    [self.delegate parameterGood:aGood];
    [self save];
    return aGood;
}
- (NSArray *)allGood
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Good"];
    NSArray *result = [[self context] executeFetchRequest:request error:nil];
    return result;
}
- (Good *)create_locality_Good
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Good" inManagedObjectContext:[self context]];
    aGood = [[Good alloc] initWithEntity:entity insertIntoManagedObjectContext:[self context]];
    
    aGood.g_id = [[ShareManager defaultManager] goodID];
    aGood.g_user_id = [[ShareManager defaultManager] goodUserID];
    aGood.g_type = [[ShareManager defaultManager] goodType];
    [self save];
    return aGood;
}


#pragma mark - private methods
-(NSArray *)_allShareID
{
    NSMutableArray *allIDArr = [[NSMutableArray alloc]init];
    NSArray *resultArr = [[NSArray alloc]initWithArray:[self all_share]];
    for (Share *item in resultArr) {
        [allIDArr addObject:item.s_id];
    }
    return allIDArr;
    
}
//所有的评论ID
-(NSArray *)_allCommentID
{
    NSMutableArray *allIDArr = [[NSMutableArray alloc]init];
    NSArray *resultArr = [[NSArray alloc]initWithArray:[self allComment]];
    for (Comment *item in resultArr) {
        [allIDArr addObject:item.c_id];
    }
    return allIDArr;
    
}
//所有的回复ID
-(NSArray *)_allReplyID
{
    NSMutableArray *allIDArr = [[NSMutableArray alloc]init];
    NSArray *resultArr = [[NSArray alloc]initWithArray:[self allReply]];
    for (Reply *item in resultArr) {
        [allIDArr addObject:item.r_id];
    }
    return allIDArr;
    
}
////所有的赞ID
//-(NSArray *)_allCommentID
//{
//    NSMutableArray *allIDArr = [[NSMutableArray alloc]init];
//    NSArray *resultArr = [[NSArray alloc]initWithArray:[self allComment]];
//    for (Comment *item in resultArr) {
//        [allIDArr addObject:item.c_id];
//    }
//    return allIDArr;
//
//}


//通过消息获得聊天列表名字
-(NSString *)getChartListIDForMessage:(Messages *)message
{
    NSString *myName = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    NSString *chartListID = nil;
    if ([myName isEqualToString:message.from_jid]) {
        chartListID = [NSString stringWithFormat:@"%@+%@",myName,message.to_jid];
    }else{
        chartListID = [NSString stringWithFormat:@"%@+%@",myName,message.from_jid];
    }
    
    return chartListID;
}


#pragma mark - public methods


#pragma mark - 聊天列表
//创建一条消息
-(Messages *)createAMessage
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
    Messages *newMessage = [[Messages alloc]initWithEntity:entity insertIntoManagedObjectContext:self.context];
    return newMessage;
    
}

//用户最近的所有聊天列表
-(NSArray *)allChartListWithRecentMessagesForUser:(NSString *)userJID
{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ChartList"];
    //按条件查询
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user_jid==%@",userJID];
    //按条件排序
    //    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"chart_date" ascending:YES];
    //    NSArray *sortDescriptorArr = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    //    [fetchRequest setSortDescriptors:sortDescriptorArr];
    
    allChartList = [self.context executeFetchRequest:fetchRequest error:nil];
    ChartList *anChartList = [allChartList lastObject];
    NSLog(@"%@",[anChartList.chartListToMessages array]);
    
    return allChartList;
    
}

//某一聊天记录的所有消息
-(NSArray *)allMessages:(ChartList *)chartList
{
    NSArray *allmessages = [NSArray arrayWithArray:[chartList.chartListToMessages array]];
    return allmessages;
}

//向聊天列表中添加消息
-(BOOL)addMessage:(Messages *)nMessage intoChartLists:(NSMutableArray *)ChartLists
{
    NSEntityDescription *chartList = [NSEntityDescription entityForName:@"ChartList" inManagedObjectContext:self.context];
    //获得message的chartlistID
    NSString *chartListIDForMeg = [self getChartListIDForMessage:nMessage];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ChartList"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"chartList_id==%@",chartListIDForMeg];
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:nil];
    if ([self.context countForFetchRequest:fetchRequest error:nil]) {
        ChartList *currentChartList = [result lastObject];
        [currentChartList addChartListToMessagesObject:nMessage];
        [currentChartList setTotal_num:[NSNumber numberWithInteger:currentChartList.chartListToMessages.count]];
        for (int i = 0; i < ChartLists.count; i++) {
            ChartList *obj = [ChartLists objectAtIndex:i];
            if ([obj.chartList_id isEqualToString:chartListIDForMeg]) {
                [obj addChartListToMessagesObject:nMessage];
                break;
            }
        }
        
        [self save];
    }else{
        ChartList *newChartList = [[ChartList alloc]initWithEntity:chartList insertIntoManagedObjectContext:self.context];
        [newChartList setChartList_id:chartListIDForMeg];
        [newChartList setUser_jid:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
        [newChartList addChartListToMessagesObject:nMessage];
        [newChartList setTotal_num:[NSNumber numberWithInteger:newChartList.chartListToMessages.count]];
        [ChartLists addObject:newChartList];
        [self save];
        
    }
    return YES;
}

//更新聊天列表未读已读信息
-(BOOL)upDataChartList:(ChartList *)chartList
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"ChartList" inManagedObjectContext:self.context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"chartList_id==%@",chartList.chartList_id]];
    NSArray *chartListArr = [self.context executeFetchRequest:request error:nil];
    ChartList *currentCL = [chartListArr objectAtIndex:0];
    [currentCL setUnread_num:chartList.unread_num];
    [currentCL setTotal_num:chartList.total_num];
    
    [self save];
    return YES;
}

//添加某一用户好友列表
-(BOOL)addChartListFromFriends:(NSArray *)friendList
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChartList" inManagedObjectContext:self.context];
    
    
    for (NSString *friend in friendList) {
        NSString *myName = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
        NSString *chartListID = [NSString stringWithFormat:@"%@+%@",myName,friend];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ChartList"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"chartList_id==%@",chartListID]];
        if (![self.context countForFetchRequest:request error:nil]) {
            ChartList *newChartList = [[ChartList alloc]initWithEntity:entity insertIntoManagedObjectContext:self.context];
            [newChartList setChartList_id:chartListID];
            [newChartList setUser_jid:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID]];
            [self save];
            
        }
    }
    return YES;
    
}


@end
