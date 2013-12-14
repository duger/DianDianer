//
//  TuYaViewController.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "TuYaViewController.h"
#import "UIColor+Random.h"
#import "Singleton.h"
#import "ShareManager.h"
#import "ShareViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DXAlertView.h"
#import <CoreText/CoreText.h>

@interface TuYaViewController  ()
{

}



@end

@implementation TuYaViewController
{
    NSString        *filePath;
    
    BOOL            isOpen;                 //是否打开 颜色和画笔
    BOOL            isShape;                //是否打开 样式
    
    NSArray         *colorImageArray;       //画笔颜色 图片字符串组
    NSArray         *colorArray;
    NSArray         *brushImageArray;       //画笔大小 图片字符串组
    NSArray         *shapeImageArray;       //画笔样式 图片字符串组
    NSArray         *ziTiStr;               //字体
    
    UIButton        *showColoraAndWidth;    //显示 当前颜色和大小 的状态
    UIButton        *showShape;             //显示 当前样式 的状态
    
    UIButton        *bigButton;             //控制颜色和画笔按钮的 弹出与回收的按钮
    
    Accesory        *accesory;              //可编辑的文字区域 对象
    float           size;                   //用来记录字体的大小
    int             tagID;
    
}

@synthesize aPainterView;
@synthesize aImage;
@synthesize aImageData;

@synthesize imageCropperView;
@synthesize background;
@synthesize cancel;
@synthesize ok;

//#define IS_IPHONE5 (([[[UIDevice  currentDevice]systemVersion]floatValue]>=7) ? height : NO)
static float height;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      
    }
    return self;
}
- (void)awakeFromNib
{
    if (IS_IPHONE5) {
        height = ScreenHeight;
    }else
    {
        height = ScreenHeight -10;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
        self.contentView.frame = CGRectMake(0, height - 60, 320, 100);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
        self.contentView.frame = CGRectMake(0, height - 60, 320, 100);
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBackground320*568"]];
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];

    isOpen = NO;
    isShape = NO;
    [self initPainterView];         //初始化画板
    [self initArray];               //初始化数组
    [self initColorAndWidthButton]; //初始化画笔颜色和画笔大小按钮
    [self initShapeButton];         //初始化控制 画笔样式 的按钮
    
   
    
        //控制 画图颜色和大小 按钮
    bigButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height - 20 , 30, 30)];
    [bigButton setImage:[UIImage imageNamed:@"PCB"] forState:UIControlStateNormal];
    [self.view addSubview:bigButton];
    [bigButton addTarget:self action:@selector(openColorAndWitdth) forControlEvents:UIControlEventTouchUpInside];
    
    //显示 画图颜色和大小
    showColoraAndWidth = [[UIButton alloc] initWithFrame:bigButton.frame];
    showColoraAndWidth.userInteractionEnabled = NO;
    [bigButton addSubview:showColoraAndWidth];
    //显示当前画笔状态   默认 蓝色 6像素
    [showColoraAndWidth setImage:[UIImage imageNamed:[brushImageArray objectAtIndex:7]] forState:UIControlStateNormal];
    showColoraAndWidth.frame = CGRectMake(0, height - 20 , 6, 6);
    showColoraAndWidth.center = CGPointMake(bigButton.frame.size.width/2, bigButton.frame.size.height/2);
    aPainterView.lineColor = [UIColor customBlue];
    aPainterView.lineWidth = 6.0f;
    
    //控制 画笔样式控制 按钮
    UIButton *burshShape = [[UIButton alloc] initWithFrame:CGRectMake(kWIDTH_SCREEN - 30, height - 20 , 30, 30)];
    [burshShape setImage:[UIImage imageNamed:@"PCB"] forState:UIControlStateNormal];
    [self.view addSubview:burshShape];
    [burshShape addTarget:self action:@selector(selectShape) forControlEvents:UIControlEventTouchUpInside];
    //显示当前画笔样式 默认曲线
    showShape =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [showShape setImage:[UIImage imageNamed:[shapeImageArray objectAtIndex:shapeImageArray.count - 2]] forState:UIControlStateNormal];
    showShape.userInteractionEnabled = NO;
    [burshShape addSubview:showShape];
}

#pragma mark   动画
- (void)openColorAndWitdth      //打开或关闭 颜色和画笔   的动画效果（带反弹）
{
    isOpen = !isOpen;
    if (isOpen)
    {
        for (int i = 1; i <= colorArray.count; i++) {
            UIButton *colorButton = (UIButton *)[self.view viewWithTag:100+i];
            UIButton *brushButton = (UIButton *)[self.view viewWithTag:1000+i];
            colorButton.hidden = NO;
            [UIButton animateWithDuration:0.35 +0.005*i animations:^{
                colorButton.frame = CGRectMake(0, height - 20 - 28*i -(i*i - i) , 30, 22);
                brushButton.center = CGPointMake(20+30*i + i*i,  bigButton.center.y);
            } completion:^(BOOL finished) {
                [UIButton animateWithDuration:0.35 +0.005*i animations:^{
                    colorButton.frame = CGRectMake(0, height - 20 - 28*i, 30, 22);
                    brushButton.center = CGPointMake(20+30*i, bigButton.center.y);
                }];
            }];
        }
    }else
    {
        for (int i = 1; i <= colorArray.count; i++) {
            UIButton * colorButton = (UIButton *)[self.view viewWithTag:100+i];
            UIButton * brushButton = (UIButton *)[self.view viewWithTag:1000+i];
            [UIButton animateWithDuration:0.35 +0.005*i animations:^{
                colorButton.frame = CGRectMake(0, height - 20+5, 30, 22);
                brushButton.frame = CGRectMake(0, height - 20, 30, 30);
            }];
        }
    }
}
- (void)selectShape             //打开或关闭 画笔样式  的动画效果(包含旋转)
{
    isShape = !isShape;
    if (isShape)   //打开 样式按钮组
    {
        [UIButton animateWithDuration:0.35 animations:^{
            //顺时针旋转60度
            showShape.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / 180.0f);
        } completion:^(BOOL finished) {
            //旋转完毕 打开 画笔样式
            for (int i = 1; i <= shapeImageArray.count; i++) {
                UIButton *shape = (UIButton *)[self.view viewWithTag:200+i];
                [UIButton animateWithDuration:0.35 +0.008*i animations:^{
                    shape.frame = CGRectMake(kWIDTH_SCREEN - 30, height - 20 - 34*i -(i*i -i), 30, 30);
                } completion:^(BOOL finished) {
                    [UIButton animateWithDuration:0.35 +0.008*i animations:^{
                        shape.frame = CGRectMake(kWIDTH_SCREEN - 30, height - 20 - 34*i , 30, 30);
                    }];
                }];
            }
        }];
    }else    //关闭 样式按钮组
    {
        for (int i = 1; i <= brushImageArray.count; i++) {
             UIButton *shape = (UIButton *)[self.view viewWithTag:200+i];
            [UIButton animateWithDuration:0.35 animations:^{
                shape.frame = CGRectMake(kWIDTH_SCREEN - 30, height - 20, 30, 30);
            } completion:^(BOOL finished) {
                [UIButton animateWithDuration:0.35 animations:^{
                    showShape.transform = CGAffineTransformMakeRotation((0.0f * M_PI) / 180.0f);
                }];       //收回完毕 关闭 画笔样式
            }];
        }
    }
}
- (void)bigButtonBecomeBig      //总按钮  变大效果
{
    [UIButton animateWithDuration:0.25 animations:^{
        bigButton.frame = CGRectMake(0 - 5, height - 20 - 5 , 40, 40);
        showColoraAndWidth.center = CGPointMake(bigButton.frame.size.width/2, bigButton.frame.size.height/2);
    } completion:^(BOOL finished) {
        // 按钮恢复
        [UIButton animateWithDuration:0.25 animations:^{
            bigButton.frame = CGRectMake(0, height - 20 , 30, 30);
            showColoraAndWidth.center = CGPointMake(bigButton.frame.size.width/2, bigButton.frame.size.height/2);;
        }];
    }];
}

#pragma mark 改变  画笔颜色 画笔宽度 画笔样式 Methods
- (void)changePainterColor:(UIButton *)sender   //改变  画笔颜色
{
    switch (sender.tag) {
        case 101:
            aPainterView.lineColor = [UIColor customWhite];
            break;
        case 102:
            aPainterView.lineColor = [UIColor customOranger];
            break;
        case 103:
            aPainterView.lineColor = [UIColor customBlack];
            break;
        case 104:
            aPainterView.lineColor = [UIColor customPurple3];
            break;
        case 105:
            aPainterView.lineColor = [UIColor customCayn];
            break;
        case 106:
            aPainterView.lineColor = [UIColor customPurple2];
            break;
        case 107:
            aPainterView.lineColor = [UIColor customGreen];
            break;
        case 108:
            aPainterView.lineColor = [UIColor customBlue];
            break;
        case 109:
            aPainterView.lineColor = [UIColor redColor];
            break;
        default:
            break;
    }
    //更新显示画图颜色和大小按钮的状态
    showColoraAndWidth.backgroundColor = [colorArray objectAtIndex:sender.tag -101];
    [showColoraAndWidth setImage:[UIImage imageNamed:[brushImageArray objectAtIndex:sender.tag - 101] ] forState:UIControlStateNormal];
    
    for (int i = 1; i <= brushImageArray.count; i++)
    { //让显示画笔大小的按钮颜色跟当前选择画笔颜色一致
        
        UIButton * button = (UIButton *)[self.view viewWithTag:10000+i];
        [button setImage:[UIImage imageNamed:[brushImageArray objectAtIndex:sender.tag - 101]] forState:UIControlStateNormal];
    }

    [UIButton  beginAnimations:nil context:NULL];
    [UIButton  setAnimationDuration:0.35];
    sender.frame = CGRectMake(30, height - 20 - 34*(sender.tag - 100), 40, 40);
    [UIButton commitAnimations];
    
    [UIButton  beginAnimations:nil context:NULL];
    [UIButton  setAnimationDuration:0.35];
    sender.frame = CGRectMake(0, height - 20 , 30, 30);
    [UIButton commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(bigButtonBecomeBig) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openColorAndWitdth) userInfo:nil repeats:NO];
    if (accesory) { //如果此时aTextView存在 则更新 aTextView的文本颜色
        [self setTextViewFontColor:accesory];
    }
    
}
- (void)changePainterBrush:(UISlider *)sender   //改变  画笔宽度
{
    aPainterView.lineWidth = (sender.tag - 1000)* 3;
    showColoraAndWidth.bounds = CGRectMake(showColoraAndWidth.frame.size.width/2,showColoraAndWidth.frame.size.height/2, aPainterView.lineWidth, aPainterView.lineWidth);
    
    
    [UIButton  beginAnimations:nil context:NULL];
    [UIButton  setAnimationDuration:0.35];
    sender.frame = CGRectMake(10+30*(sender.tag - 1000) ,bigButton.center.y - 50, 40, 40);
    
    [UIButton commitAnimations];
    [UIButton  beginAnimations:nil context:NULL];
    [UIButton  setAnimationDuration:0.35];
    sender.frame = CGRectMake(0, height - 20 , 30, 30);
    [UIButton commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(bigButtonBecomeBig) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openColorAndWitdth) userInfo:nil repeats:NO];
    
    if (accesory) { //如果此时aTextView存在 则更新 aTextView的文本字体
        [self setTextViewFont:accesory index:tagID];
    }
}
- (void)changePainterShape:(UIButton *)sender   //改变  画笔样式
{
    switch (sender.tag) {
        case 201:  //实心椭圆
            aPainterView.drawTool = ACEDrawingToolTypeEllipseFill;
            break;
            
        case 202: //椭圆
            aPainterView.drawTool = ACEDrawingToolTypeEllipseStroke;
            break;
            
        case 203: //实心矩形
            aPainterView.drawTool = ACEDrawingToolTypeRectagleFill;
            break;
            
        case 204: //矩形
            aPainterView.drawTool = ACEDrawingToolTypeRectagleStroke;
            break;
            
        case 205: //直线
            aPainterView.drawTool = ACEDrawingToolTypeLine;
            break;
            
        case 206: //任意  （默认）
            aPainterView.drawTool = ACEDrawingToolTypePen;
            break;
            
        case 207: //文字
        {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"温馨提示" contentText:@"只要在画板任意位置长按就可以添加文字哦！" leftButtonTitle:nil rightButtonTitle:@"记住了"];
            [alert show];
            alert.rightBlock = ^() {
               
            };
            alert.dismissBlock = ^() {
               
            };
            
        }
            break;
        default:
            break;
      
    }
    [showShape setImage:[UIImage imageNamed:[shapeImageArray objectAtIndex:(sender.tag -201)] ] forState:UIControlStateNormal];
    [self selectShape];
}

#pragma mark 画板的（清除 撤销  重做 保存 背景)Methods
- (IBAction)clear:(UIButton *)sender   //清除画布
{
    [aPainterView clear];
}
- (IBAction)redo:(UIButton *)sender    //撤销
{
    [aPainterView undoLatestStep];
    [self updateButtonStatus];
}
- (IBAction)undo:(UIButton *)sender    //重做
{
    NSLog(@"chongzuo");
    [aPainterView redoLatestStep];
    [self updateButtonStatus];
}
- (IBAction)save:(UIButton *)sender    //保存
{
    static int i = 0;
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [documentPath stringByAppendingFormat:@"/%d.png",i++];
    aImageData = [NSKeyedArchiver archivedDataWithRootObject:[self getCurrentImage]];
    [aImageData writeToFile:filePath atomically:YES];
    UIImageWriteToSavedPhotosAlbum(aImage, nil, nil, nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"涂鸦已保存在本地相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"去相册查看",nil];
    [alertView show];
}
#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            NSLog(@"1");
            [self actionSheet:nil clickedButtonAtIndex:1];
            break;
            
        default:
            break;
    }
}

- (IBAction)changebackround:(UIButton *)sender    //改变画板背景
{
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"选择背景" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:@"从相册选择",@"随机颜色", nil];
    [aActionSheet showInView:self.view];
}

#pragma mark - ACEDrawing View Delegate
- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}
- (void)updateButtonStatus
{
    self.redoButton.enabled = [aPainterView canUndo];
    self.undoButton.enabled = [aPainterView canRedo];
}

#pragma mark UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            UIImagePickerController *pic = [[UIImagePickerController alloc] init];
            pic.delegate = self;
            pic.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pic.allowsEditing = YES;
            [self presentViewController:pic animated:YES completion:^{ }];
        }
            break;
        case 2:
        {
            aPainterView.backgroundColor = [UIColor randomColor];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *temp = [info objectForKey:UIImagePickerControllerOriginalImage];
   
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (background) {
            [self.view bringSubviewToFront:background];
            background.hidden = NO;
            if (IS_IPHONE5) {
                background.frame = self.view.frame;
            }else
            {
                background.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 20, self.view.frame.size.width, self.view.frame.size.height);
            }
            
            background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBackground320*568"]];;
            background.alpha = 0.8;
        }
        if (imageCropperView ) {
            imageCropperView.hidden = NO;
            imageCropperView.frame = aPainterView.frame;
            imageCropperView.layer.borderWidth = 1.0f;
            imageCropperView.layer.borderColor = [UIColor redColor].CGColor;
            [imageCropperView setup];
            imageCropperView.image = temp;
          
        }
        if (cancel) {
            //取消按钮
            cancel.frame = CGRectMake(80, bigButton.frame.origin.y, 60, 30);
            [cancel setTitle:@"返回" forState:UIControlStateNormal];
            [cancel addTarget:self action:@selector(cancelForCorpImage) forControlEvents:UIControlEventTouchUpInside];
            cancel.hidden = NO;
        }
        if (ok) {
            //确认按钮
            ok.frame = CGRectMake(100+80, bigButton.frame.origin.y, 60, 30);
            [ok setTitle:@"裁剪" forState:UIControlStateNormal];
            [ok addTarget:self action:@selector(okForCorpImage) forControlEvents:UIControlEventTouchUpInside];
            ok.hidden= NO;
        }
        }];
}

//取消裁剪
- (void)cancelForCorpImage
{
    [imageCropperView reset];
    background.hidden = YES;
    
}

//确认裁剪
- (void)okForCorpImage
{
    [imageCropperView finishCropping];
    [self painterBackground:imageCropperView.croppedImage];
    background.hidden = YES;
}

- (UIImage *)getCurrentImage     //获取当前绘画的images
{
    UIGraphicsBeginImageContext(aPainterView.bounds.size);
    [aPainterView.layer renderInContext:UIGraphicsGetCurrentContext()];
    aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aImage;
}
- (IBAction)didClickBack:(UIBarButtonItem *)sender    //返回首页
{
    //    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
    
}
- (IBAction)didClickShare:(UIBarButtonItem *)sender  //前往分享
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([Singleton instance].fromTuYa) {
            [self.delegate tuYaGoToShare];
        }
    }];
    static int i = 0;
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [documentPath stringByAppendingFormat:@"/%d.png",i++];
    UIImage *image = [self getCurrentImage];
    //    aImageData = [NSKeyedArchiver archivedDataWithRootObject:aImage];
    aImageData = UIImagePNGRepresentation(image);
    [aImageData writeToFile:filePath atomically:YES];
    UIImageWriteToSavedPhotosAlbum(aImage, nil, nil, nil);
    [ShareManager defaultManager].tempImagePath = filePath;
    //    shareVC.shareImage.image = image;
    if (![Singleton instance].fromTuYa) {
        [self.delegate didFinishTuYa];
    }
    
}

#pragma mark -GestureRecognizer Methods 
BOOL isExpend;
- (void)tapGestureForPainter:(UITapGestureRecognizer *)sender   //轻拍（双击）手势 放大画板
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    isExpend = !isExpend;
    if (isExpend)
    {
        if (IS_IPHONE5) {
            if (IS_IPHONE5SCREEN) {
                [UIView animateWithDuration:0.35f animations:^{
                    aPainterView.frame =  CGRectMake((kWIDTH_SCREEN -241*1.3)/2, 67, 241*1.3, 322*1.3);
                } completion:^(BOOL finished) {
                      NSLog(@"4寸IOS7"); //ok 扩大
                }];
            }
            else
            {
//                [UIView animateWithDuration:0.35f animations:^{
//                    aPainterView.frame = CGRectMake((kWIDTH_SCREEN -241*1.1)/2, 47, 241*1.1, 322*1.1);
//                } completion:^(BOOL finished) {
                    NSLog(@"3.5寸IOS7"); //ok 不扩
//                }];
            }
        }else
        {
            if (IS_IPHONE5SCREEN)
            {
                [UIView animateWithDuration:0.35 animations:^{
                    aPainterView.frame = CGRectMake((kWIDTH_SCREEN -241*1.3)/2, 47, 241*1.3, 322*1.3);
                } completion:^(BOOL finished) {
                     NSLog(@"4寸IOS6");
                }];
            }
            else
            {
                NSLog(@"3.5寸IOS6");
            }
            
        }
    }
    else
    {
        if (IS_IPHONE5) {
            if (IS_IPHONE5SCREEN) {
                [UIView animateWithDuration:0.35f animations:^{
                    aPainterView.frame =  CGRectMake((kWIDTH_SCREEN -241*1.1)/2, 77, 241*1.1, 322*1.1);
                } completion:^(BOOL finished) {
                    NSLog(@"4寸IOS7"); //ok 缩回
                }];
            }
            else
            {
                NSLog(@"3.5寸IOS7");// 无变化
            }
        }else
        {
            if (IS_IPHONE5SCREEN) {
                [UIView animateWithDuration:0.35 animations:^{
                    aPainterView.frame = CGRectMake((kWIDTH_SCREEN -241*1.1)/2, 75, 241*1.1, 322*1.1);
                } completion:^(BOOL finished) {
                    NSLog(@"4寸IOS6");
                }];
            }
            else
            {
                NSLog(@"3.5寸IOS6");
            }
            
        }
       
    }
    if (imageCropperView.croppedImage) {
        [self painterBackground:imageCropperView.croppedImage];
    }else
    {
        [self painterBackground:[UIImage imageNamed:@"painter"]];
    }
    [UIView commitAnimations];
    [self redo:nil];

}
- (void)longPressGestureForPainter:(UILongPressGestureRecognizer *)sender // 长按手势 在画板输入文字
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint currentPoint = [sender locationInView:aPainterView]; //获取手势触发点的位置
        accesory = [[Accesory alloc] initWithFrame:CGRectMake(currentPoint.x, currentPoint.y, aPainterView.frame.size.width - currentPoint.x - 40, 80)];
        accesory.delegate = self;
        [aPainterView addSubview:accesory];
        [self redo:nil];
    }
}

#pragma mark AccesoryDelegate Methods
-(void)setTextViewFont:(Accesory *)aAccesory index:(int)index
{
    if (index == 4) {
        [accesory.aTextView resignFirstResponder];
    }else
    {
    ziTiStr = @[@"FZMiaoWuS-GB",@"Kim's GirlType",@"QXyingbixing",@"FZZJ-TTMBFONT",@"FZMiaoWuS-GB"];
    aAccesory.aTextView.font = [UIFont fontWithName:[ziTiStr objectAtIndex:index] size:[self getTextViewFontWidth:aPainterView.lineWidth]];
    tagID  = index;
    }
}
- (void)setTextViewFontColor:(Accesory *)aAccesory
{
    aAccesory.aTextView.textColor = aPainterView.lineColor;
}
- (void)setTextViewBoardFontColor:(Accesory *)aAccesory button:(UIButton *)button
{
    [button setTitleColor:aPainterView.lineColor forState:UIControlStateNormal];
    button.titleLabel.textColor = aPainterView.lineColor;
}
//根据画笔大小来规定文本字体的大小
- (float)getTextViewFontWidth:(float)aWidth
{
    float fontWidth;
    switch ((int)aWidth) {
        case 3:     fontWidth = 10;
            break;
        case 6:     fontWidth = 12;
            break;
        case 9:     fontWidth = 14;
            break;
        case 12:    fontWidth = 16;
            break;
        case 15:    fontWidth = 20;
            break;
        case 18:    fontWidth = 24;
            break;
        case 21:    fontWidth = 30;
            break;
        default:    fontWidth = 14;  //默认
            break;
    }
    return fontWidth;

}

#pragma mark Private Methods
- (void)initArray  //初始化 图片字符串组
{
//    colorImageArray = @[@"black",@"red",@"green",@"blue",@"random",@"oranger",@"greenBlue",@"purple",@"purple2"];
    colorArray = [NSArray arrayWithObjects:[UIColor customWhite], [UIColor customOranger],[UIColor customBlack],[UIColor customPurple3],[UIColor customCayn],[UIColor customPurple2],[UIColor customGreen],[UIColor customBlue],[UIColor redColor],nil];
    brushImageArray = @[@"white_",@"oranger_",@"black_",@"purple_",@"cayn_",@"purple2_",@"green1_",@"blue_",@"red_"];
    shapeImageArray = @[@"shape-RectF",@"shape-Rect",@"shape-RF",@"shape-R",@"shape-L",@"shape-S",@"shape-T"];
}
- (void)initPainterView  //初始化  画板
{
    
  
    //241*322
    if (IS_IPHONE5) {
        if (IS_IPHONE5SCREEN) {
            aPainterView = [[ACEDrawingView alloc]initWithFrame:CGRectMake((kWIDTH_SCREEN -241*1.1)/2, 77, 241*1.1, 322*1.1)];
            NSLog(@"4寸IOS7"); //ok
        }
        else
        {
            aPainterView = [[ACEDrawingView alloc]initWithFrame:CGRectMake((kWIDTH_SCREEN -241)/2, 67, 241, 322)];
            NSLog(@"3.5寸IOS7"); //ok 不可扩展
        }
    }else
    {
        if (IS_IPHONE5SCREEN) {
            aPainterView = [[ACEDrawingView alloc] initWithFrame:CGRectMake((kWIDTH_SCREEN -241*1.1)/2, 75, 241*1.1, 322*1.1)];
            NSLog(@"4寸IOS6");//ok
        }
        else
        {
            aPainterView = [[ACEDrawingView alloc] initWithFrame:CGRectMake((kWIDTH_SCREEN -241)/2, 57, 241, 322)];
              NSLog(@"3.5寸IOS6");//ok 不可扩展
        }
        
    }
    [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
   

    [self painterBackground:[UIImage imageNamed:@"painter"]];
    aPainterView.layer.borderWidth = 2.0;
    [self.view addSubview:aPainterView];
    aPainterView.delegate = self;
    
    //为画板添加长按手势
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureForPainter:)];
    [aPainterView addGestureRecognizer:longPressGesture];
   
      //为画板添加轻拍手势
     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureForPainter:)];
    tapGesture.numberOfTapsRequired = 2;
    [aPainterView addGestureRecognizer:tapGesture];
    
}
- (void)painterBackground:(UIImage *)tempImage  //画板背景色
{
    CGFloat width = aPainterView.frame.size.width;
    CGFloat height = aPainterView.frame.size.height;
    UIImage  *img_a;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [tempImage drawInRect:CGRectMake(0, 0, width, height)];
    img_a = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    aPainterView.backgroundColor = [UIColor colorWithPatternImage:img_a];
}
- (void)initColorAndWidthButton    //初始化  画笔颜色和画笔大小  按钮组
{
    for (int i = 1; i <= colorArray.count; i++)
    {
        //画笔颜色 按钮
        UIButton * color = [[UIButton alloc] initWithFrame:CGRectMake(0, height - 20 , 30, 22)];
        color.hidden = YES;
        color.backgroundColor = [colorArray objectAtIndex:i-1];
        [self.view addSubview:color];
        [color addTarget:self action:@selector(changePainterColor:) forControlEvents:UIControlEventTouchUpInside];
        color.tag = 100+i;
    }
    for (int i = 1; i <= 7; i++)
    {
        //画笔大小按钮 （背景）
        UIButton *brushWidth = [[UIButton alloc] initWithFrame:CGRectMake(0, height - 20 , 30,  30)];
        brushWidth.tag = 1000+i;
        [brushWidth setImage:[UIImage imageNamed:@"brushBackground"] forState:UIControlStateNormal];
        [self.view addSubview:brushWidth];
        [brushWidth addTarget:self action:@selector(changePainterBrush:) forControlEvents:UIControlEventTouchUpInside];
        
        //用来显示的画笔大小按钮
        UIButton *showWidth = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 3*i, 3*i)];
        showWidth.tag = 10000+i;
        showWidth.center = CGPointMake(brushWidth.frame.size.width/2, brushWidth.frame.size.height/2);
        //默认蓝色
        [showWidth setImage:[UIImage imageNamed:[brushImageArray objectAtIndex:7]] forState:UIControlStateNormal];
        showWidth.userInteractionEnabled = NO;
        [brushWidth addSubview:showWidth];
        
    }
}
- (void)initShapeButton //初始化控制画笔样式的 按钮组
{
    for (int i = 1; i <= shapeImageArray.count; i++)
    {
        //画笔样式 按钮
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(kWIDTH_SCREEN - 30, height - 20 , 30, 30)];
        button.tag = 200+i;
        [button setImage:[UIImage imageNamed:[shapeImageArray objectAtIndex:i-1]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changePainterShape:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }

}
- (void)viewDidUnload
{
    [self setTopView:nil];
    [self setBackground:nil];
    [self setImageCropperView:nil];
    [self setCancel:nil];
    [self setOk:nil];
    [super viewDidUnload];
}
@end
