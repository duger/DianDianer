//
//  ShareManager.m
//  DianDianEr
//
//  Created by Duger on 13-10-28.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "ShareManager.h"
#import "Singleton.h"
#import "lame.h"
#import "ShareViewController.h"
#import "FirstViewController.h"

#define kManagerUpload_URL @"http://114.215.104.163/team_seven/share/uploadImages.php"
#define kUploadComment_URL @"http://114.215.104.163/team_seven/comment/uploadComment.php"
#define kUploadReply_URL @"http://114.215.104.163/team_seven/reply/uploadReply.php"
#define kUploadGood_URL @"http://114.215.104.163/team_seven/good/uploadGood.php"




@implementation ShareManager
{
    NSInteger bodyLength;
    NSMutableData *mutableData;
    CGFloat   _sampleRate;
    CompletionBlock _completionBlock;
    
    NSString        *boundary;              //我是分割线
    NSString        *contentType;           //文件格式
    NSString        *content_Type;          //发送body内的内容类型
}
static ShareManager *s_shareMangager = nil;
+(ShareManager *)defaultManager
{
    @synchronized(self)
    {
        if (s_shareMangager == nil) {
            s_shareMangager = [[ShareManager alloc]init];
        }
        
    }
    return s_shareMangager;
}

- (id)init
{
    self = [super init];
    if (self) {
        boundary = @"--------mutipart---------upload-----";
        contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        content_Type = @"Content-Type: application/octet-stream\r\n\r\n";
        [self cleanShare];
    }
    return self;
}

#pragma mark - 上传 分享 
-(void)uploadWithCompletionBlock:(CompletionBlock) completion
{
    if ([Singleton instance].isUploading) {
        return;
    }
    _completionBlock = completion;
    [Singleton instance].isUploading = ![Singleton instance].isUploading;
    self.inPutImagePath = [ShareManager defaultManager].tempImagePath;
    self.inPutSoundsPath = [ShareManager defaultManager].inPutSoundsPath;
    NSURL *url = [NSURL URLWithString:kManagerUpload_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[self shareBody]];
    
    //异步实现上传文件
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//share 的 body
- (NSMutableData *)shareBody
{
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:self.inPutImagePath];
    NSData *soundData = [[NSData alloc]initWithContentsOfFile:self.inPutSoundsPath];
    NSString *shareid = [[DiandianCoreDataManager shareDiandianCoreDataManager].aShare.s_id description];
    NSString *uid = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    NSString *content = [ShareManager defaultManager].shareContents;
    NSString *locationName = [ShareManager defaultManager].locationPlace;
    NSDate *createDate = [DiandianCoreDataManager shareDiandianCoreDataManager].aShare.s_createdate;
    double longitude = self.latitude;
    double latitude = self.longitude;
    
    NSString *jsonContent = [NSString stringWithFormat:@"{\"shareID\":\"%@\",\"uID\":\"%@\",\"shareContent\":\"%@\",\"shareLocationName\":\"%@\",\"longitude\":%f,\"latitude\":%f,\"createDate\":\"%@\"}",shareid,uid,content,locationName,longitude,latitude,createDate];
    
    NSString *content_Disposition1;
    if ([self.inPutImagePath isEqualToString:@""]) {
        content_Disposition1 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"imagefile\"\r\n"];
    }else{
        
        content_Disposition1 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"imagefile\"; filename=\"%@.png\"\r\n",shareid];
    }
    NSString *content_Disposition2;
    if ([self.inPutSoundsPath isEqualToString:@""]) {
        content_Disposition2 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"musicfile\"\r\n"];
    }else{
        content_Disposition2 = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"musicfile\"; filename=\"%@.mp3\"\r\n",shareid];
    }
    
    NSString *content_Disposition3 = [NSString stringWithFormat:@"Content-Disposition: text/html; name=\"jsonContent\"\r\n"];
    
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition3 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition1 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition2 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:soundData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    bodyLength = body.length;
    return body;
}

#pragma mark - 上传 评论
-(void)uploadComment
{
    NSURL *url = [NSURL URLWithString:kUploadComment_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    //文件格式
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[self commentBody]];
    
    //异步实现上传文件
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}
//comment 的 body
- (NSMutableData *)commentBody
{
    NSString *content   = [ShareManager defaultManager].commentContent;
    NSString *uid       = [ShareManager defaultManager].userID;
    NSDate   *date      = [ShareManager defaultManager].creatDate;
    NSString *shareID   = [ShareManager defaultManager].shareID;
    NSString *commentID = [ShareManager defaultManager].commentID;
    
    //JSON内容
    NSString *jsonContent = [NSString stringWithFormat:@"{\"shareID\":\"%@\",\"commentID\":\"%@\",\"userID\":\"%@\",\"commentDate\":\"%@\",\"commentContent\":\"%@\"}",shareID,commentID,uid,date,content];
    NSString *content_Disposition3 = [NSString stringWithFormat:@"Content-Disposition: text/html; name=\"jsonContent\"\r\n"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition3 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    bodyLength = body.length;
    return body;
}

#pragma mark - 上传 回复
-(void)uploadReply
{
    NSURL *url = [NSURL URLWithString:kUploadReply_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
   
    //文件格式
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[self replyBody]];
    
    //异步实现上传文件
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//reply 的 body
- (NSMutableData *)replyBody
{
    //JSON内容
    NSString *content = [ShareManager defaultManager].replyContent;
    NSString *replyID = [ShareManager defaultManager].replyID;
    NSString *replyToID = [ShareManager defaultManager].replyToID;
    NSString *replyFromID = [ShareManager defaultManager].replyFromID;
    NSDate *date = [ShareManager defaultManager].replyDate;
    NSString *commentID = [ShareManager defaultManager].replyCommentID;
    
    NSString *jsonContent = [NSString stringWithFormat:@"{\"commentID\":\"%@\",\"replyID\":\"%@\",\"replyContent\":\"%@\",\"replyDate\":\"%@\",\"replyToID\":\"%@\",\"replyFromID\":\"%@\"}",replyID,commentID,content,date,replyToID,replyFromID];
    NSString *content_Disposition3 = [NSString stringWithFormat:@"Content-Disposition: text/html; name=\"jsonContent\"\r\n"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",   boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition3 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    bodyLength = body.length;
    return body;
}

#pragma mark - 上传 赞
-(void)uploadGood
{
    NSURL *url = [NSURL URLWithString:kUploadGood_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    //文件格式
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[self goodBody]];
    
    //异步实现上传文件
    [NSURLConnection connectionWithRequest:request delegate:self];
}

//reply 的 body
- (NSMutableData *)goodBody
{
    //JSON内容
    NSString *shareID = [ShareManager defaultManager].shareID;
    int      goodID = self.goodID;
    NSString *goodUserID = [ShareManager defaultManager].goodUserID;
    NSData   *goodType = [ShareManager defaultManager].goodType;
    
    NSString *jsonContent = [NSString stringWithFormat:@"{\"shareID\":\"%@\",\"goodID\":\"%d\",\"goodUserID\":\"%@\",\"goodType\":\"%@\"}",shareID,goodID,goodUserID,goodType];
    NSString *content_Disposition3 = [NSString stringWithFormat:@"Content-Disposition: text/html; name=\"jsonContent\"\r\n"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Disposition3 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[content_Type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    bodyLength = body.length;
    return body;
}


-(void)toMp3
{
//    NSString *cafFilePath =[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    NSString *cafFilePath = [[NSBundle mainBundle] pathForResource:@"2013-10-31 13:20:41 +0000" ofType:@"aac"];    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    NSLog(@"艾米披散%@",mp3FilePath);
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

-(void)convertMp3Finish
{
    
}

#pragma mark - NSURL connectionDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{

    mutableData = [[NSMutableData alloc] init];
    return request;
}

//获取发送的进度
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    CGFloat progress = (CGFloat)totalBytesWritten / bodyLength;
    [self.delegate changeUploadProgress:(CGFloat)progress];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
}

//上传成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([Singleton instance].isUploadingShare == YES) {
        [self.delegate changeUploadProgress:1.0f];
        [self.delegate setProgress:1.0f];
        NSString *content = [[NSString alloc] initWithData:mutableData encoding:NSUTF8StringEncoding];
        [Singleton instance].url = content;
        [self cleanShare];
        [Singleton instance].isUploading = ![Singleton instance].isUploading;
        [self _createAlertViewWithMessage:@"分享成功"];
    }
    if ([Singleton instance].isUploadingComment == YES) {
        [Singleton instance].isUploadingComment = ![Singleton instance].isUploadingComment;
        [self _createAlertViewWithMessage:@"评论成功"];
    }
    if ([Singleton instance].isUploadingReply == YES) {
        [Singleton instance].isUploadingReply = ![Singleton instance].isUploadingReply;
        [self _createAlertViewWithMessage:@"回复成功"];
    }
    if ([Singleton instance].isUploadingGood == YES) {
        [Singleton instance].isUploadingGood = ![Singleton instance].isUploadingGood;
        [self _createAlertViewWithMessage:@"赞成功"];
    }
    
}

#pragma mark AlertView Methods
- (void)_createAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([Singleton instance].isUploadingShare == YES) {
    if (buttonIndex == 0)
    {
        _completionBlock();
    }
        [Singleton instance].isUploadingShare = ![Singleton instance].isUploadingShare;

    }
    if ([Singleton instance].isUploadingComment == YES) {
        if (buttonIndex == 0) {
            self.commentContent = @"";
        }
        [Singleton instance].isUploadingComment = ![Singleton instance].isUploadingComment;
    }
   
}

-(void)cleanShare
{
    self.inPutImagePath = @"";
    self.tempImagePath = @"";
    self.shareContents = @"";
    self.inPutSoundsPath = @"";
    self.locationPlace = @"";
}

@end
