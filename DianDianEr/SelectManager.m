//
//  SelectManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "SelectManager.h"
#import "JSONKit.h"


#define kRecentShare    @"http://124.205.147.26/student/class_10/team_seven/share/downloadShare.php"
#define kRecentComment  @"http://124.205.147.26/student/class_10/team_seven/comment/downloadComment.php"
#define kRecentReply    @"http://124.205.147.26/student/class_10/team_seven/reply/downloadReply.php"
#define kRecentGood     @"http://124.205.147.26/student/class_10/team_seven/good/downloadGood.php"



@implementation SelectManager
{
    NSMutableData           *mutableData;
    NSNumber                *fileWeight;
    CGFloat                 processs;                           //分享进度条
    NSMutableDictionary     *tempDic;                           //分享or赞or评论or回复
    NSArray                 *result;
    NSDictionary            *willWriteShare;

}

static SelectManager *s_selectManager = nil;
+(SelectManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_selectManager == nil) {
            s_selectManager = [[self alloc]init];
        }
    });
    return s_selectManager;
}



- (NSArray *)downloadDateFromServiceToLocal:(int)flag
{
    NSURL *url;
    switch (flag) {
        case 1:url = [NSURL URLWithString:kRecentShare];  //下载 分享
            break;
        case 2:url = [NSURL URLWithString:kRecentComment];//下载 评论
            break;
        case 3:url = [NSURL URLWithString:kRecentReply];  //下载 回复
            break;
        case 4:url = [NSURL URLWithString:kRecentGood];   //下载 赞
            break;
        default:
            break;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error = nil;
//        result = [[NSMutableArray alloc] init];
//        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        result = [data objectFromJSONData];
//        NSLog(@"%@",result);
        [[DiandianCoreDataManager shareDiandianCoreDataManager] setDelegate:self];
        switch (flag) {
            case 1:
                
                for (NSDictionary *aShare in result) {
                    [[DiandianCoreDataManager shareDiandianCoreDataManager]createAShare:aShare];
                    
                }
                break;
            case 2:
                
                for (Share *share in result) {
                    [[DiandianCoreDataManager shareDiandianCoreDataManager] creatComment];
                    
                }
                break;
                
            default:
                break;
        }
    }];
    
//    NSLog(@"%@",result);
    return result;

}
#pragma DiandianCoreDataManagerDelegate方法
//配置 分享（将本地写入到服务器）

- (void)parameterShare:(Share *)share
{
    //格式化时间样式
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"%@",willWriteShare);
//    share = [[DiandianCoreDataManager shareDiandianCoreDataManager] aShare];
    NSLog(@"%@",share);
//    share = willWriteShare;
//    share.s_id = [tempDic objectForKey:@"s_id"];
//    NSLog(@"%@",willWriteShare.s_id);
    NSLog(@"%@",willWriteShare);
    
    NSLog(@"曹操奥覅哦%@",[willWriteShare objectForKey:@"share_id"] );

    NSLog(@"曹操奥覅哦%@",[willWriteShare valueForKey:@"share_id"]);
     NSLog(@"曹操奥覅哦%@",[willWriteShare valueForKey:@"s_longitude"]);
    
    
    share.s_id = [NSString stringWithFormat:@"%@",[willWriteShare objectForKey:@"share_id"]];
    share.s_content = (NSString *)[willWriteShare objectForKey:@"share_content"];
//    share.s_createdate = [willWriteShare objectForKey:@"share_createdate"];
    share.s_image_url = (NSString *)[willWriteShare objectForKey:@"share_image_url"];
    share.s_sound_url = (NSString *)[willWriteShare objectForKey:@"share_sound_url"];
   

    
    
//    share.s_user_id =  willWriteShare.s_user_id;
//    share.s_longitude = willWriteShare.s_longitude;
//    share.s_createdate = willWriteShare.s_createdate;
//    share.s_content =  @"caonimeinianca";
//    share.s_sound_url =  willWriteShare.s_sound_url;
//    share.s_image_url= willWriteShare.s_image_url;
//    share.s_latitude =  willWriteShare.s_latitude;
//    share.s_locationName = willWriteShare.s_locationName;
//    share.s_hot = willWriteShare.s_hot;

//    NSLog(@"刚刚刚写入到本地的数据库的分享%@",share);
}
//配置 评论（将本地写入到服务器）
- (void)parameterComment:(Comment *)comment
{
    //格式化时间样式
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    comment = [[DiandianCoreDataManager shareDiandianCoreDataManager] aComment];
    comment.c_content = [tempDic objectForKey:@"comment_content"];
    comment.c_date = [format dateFromString:[tempDic objectForKey:@"comment_date"] ];
    comment.c_id= [tempDic objectForKey:@"comment_id"];
    comment.c_user_id = [tempDic objectForKey:@"comment_user_id"];
    comment.share_id = [tempDic objectForKey:@"share_id"];
//    NSLog(@"刚刚刚写入到本地的数据库的评论%@",comment);
    
}
//配置 回复（将本地写入到服务器）
- (void)parameterReply:(Reply *)reply
{
    //格式化时间样式
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    reply = [[DiandianCoreDataManager shareDiandianCoreDataManager] aReply];
    reply.r_id = [tempDic objectForKey:@"reply_id"];
    reply.r_content = [tempDic objectForKey:@"reply_content"];
    reply.r_date = [format dateFromString:[tempDic objectForKey:@"reply_date"] ];
    reply.r_to_id = [tempDic objectForKey:@"reply_to_id"];
    reply.r_from_id = [tempDic objectForKey:@"reply_from_id"];
    reply.r_comment_id = [tempDic objectForKey:@"comment_id"];
//    NSLog(@"刚刚刚写入到本地的数据库的回复%@",reply);
}
//配置 赞 （将本地写入到服务器）
- (void)parameterGood:(Good *)good
{
    good = [[DiandianCoreDataManager shareDiandianCoreDataManager] aGood];
    good.g_id = [tempDic objectForKey:@"good_id"];
    good.g_type = [tempDic objectForKey:@"good_type"];
    good.g_user_id = [tempDic objectForKey:@"good_user_id"];
    
}
@end
//
//
//
//-(void)downloadRecentShare
//{
//    UIButtonType
//    NSURL *url = [NSURL URLWithString:kRecentShare];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//}
//
//
//-(void)downloadRecentComment
//{
//    NSURL *url = [NSURL URLWithString:kRecentComment];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//}
//
//
//-(void)downloadRecentReply
//{
//    NSURL *url = [NSURL URLWithString:kRecentReply];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//}
//
//
//-(void)downloadRecentGood
//{
//    NSURL *url = [NSURL URLWithString:kRecentGood];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//}
//#pragma mark - NSURLConnectionDelegate Methods
////发送请求
//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
//{
//    mutableData = [[NSMutableData alloc] init];
//    tempDic = [[NSMutableDictionary alloc] init];
//    return request;
//}
//
////获取发送的进度
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//{
//    processs = (CGFloat)totalBytesWritten / [fileWeight integerValue];
//    [self.delegate changedownProgress:(CGFloat)processs];
//}
////接受到响应
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    fileWeight = [[httpResponse allHeaderFields]objectForKey:@"Content-Length"];
//    mutableData = [[NSMutableData alloc]init];
//}
//
////连续获得到的数据
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    [mutableData appendData:data];
//}
//
////下载完成
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    processs = 1.0f;
//    NSError *error = nil;
//    NSMutableArray *tempDate = [NSJSONSerialization JSONObjectWithData:mutableData options:NSJSONReadingMutableContainers error:&error];
//
//    if (error) {
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"从网络获取数据失败" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
//        [alertView show];
//    }
//    NSLog(@"一条完整的分享,包含分享下的评论,回复,赞,%@",tempDate);
//    //如果更新 则将 更新(本地) 数据写入服务器
//    [[DiandianCoreDataManager shareDiandianCoreDataManager] setDelegate:self];
//    for (tempDic in tempDate)
//    {
//
//        NSLog(@"%@",tempDic);
//        NSLog(@"%@",[[DiandianCoreDataManager shareDiandianCoreDataManager] creatComment]);
//        NSArray *allShareID = [[DiandianCoreDataManager shareDiandianCoreDataManager] _allShareID];
//        NSLog(@"所有的分享ID%@",allShareID);
//
//        if (![allShareID containsObject:[tempDic objectForKey:@"share_id"]])
//        {
//            //创建一条新分享
//            [[DiandianCoreDataManager shareDiandianCoreDataManager] create_a_share];
//            NSArray *allCommentID = [[DiandianCoreDataManager shareDiandianCoreDataManager]_allCommentID];
//            NSLog(@"所有的评论ID%@",allShareID);
//            if (![allCommentID containsObject:[tempDic objectForKey:@"comment_id"]])
//            {
//                //创建一条新评论
//                [[DiandianCoreDataManager shareDiandianCoreDataManager] creatComment];
//                NSArray *allReplyID = [[DiandianCoreDataManager shareDiandianCoreDataManager]_allCommentID];
//                NSLog(@"所有的回复ID%@",allShareID);
//                if (![allReplyID containsObject:[tempDic objectForKey:@"reply_id"]])
//                {
//                    //创建一条新回复
//                    [[DiandianCoreDataManager shareDiandianCoreDataManager] creatComment];
//                }
//
//            }
//        }
//    }
//}
