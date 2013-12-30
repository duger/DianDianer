//
//  CameraViewController.m
//  DiandianerCamera
//
//  Created by Duger on 13-10-18.
//  Copyright (c) 2013年 Duger. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IphoneScreen.h"
#import "ShareViewController.h"
#import "Singleton.h"


@interface CameraViewController ()

@end

@implementation CameraViewController

static CameraViewController *s_CameraViewController = nil;
+(CameraViewController *)instence
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_CameraViewController == nil) {
            s_CameraViewController = [[self alloc]init];
        }
        
    });
    return s_CameraViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    self.navigationController.navigationBar.hidden = YES;
    UIView *bottnView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight- 60, 320, 60)];
    if (IS_IPHONE5) {
        bottnView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight- 40, 320, 60)];
    }
    bottnView.backgroundColor = [UIColor purpleColor];
    
    
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"camera_cancel.png"];
    [backBtn setImage: backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(closeNow) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    backBtn.center = CGPointMake(20, CGRectGetMidY(bottnView.bounds));
    [bottnView addSubview:backBtn];
    
    UIImage *camerImage = [UIImage imageNamed:@"camera_shoot.png"];
    UIButton *cameraBtn = [[UIButton alloc] initWithFrame:
                           CGRectMake(0, 0, camerImage.size.width, camerImage.size.height)];
    [cameraBtn setImage:camerImage forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    cameraBtn.center = CGPointMake(CGRectGetMidX(bottnView.bounds), CGRectGetMidY(bottnView.bounds));
    [bottnView addSubview:cameraBtn];
    
    UIImage *photoImage = [UIImage imageNamed:@"camera_album.png"];
    UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    [photoBtn setImage:photoImage forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.center = CGPointMake(290, CGRectGetMidY(bottnView.bounds));
    [bottnView addSubview:photoBtn];
    
    UIImage *deviceImage = [UIImage imageNamed:@"camera_button_switch_camera.png"];
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deviceBtn setBackgroundImage:deviceImage forState:UIControlStateNormal];
    [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
    [deviceBtn setFrame:CGRectMake(250, 30, deviceImage.size.width, deviceImage.size.height)];
    
    
    
    //滤镜
    NSArray *arr = [NSArray arrayWithObjects:@"原图",@"光晕",@"酒红",@"雕塑",@"哥特",@"锐色",@"素描",@"负片",@"马赛克",@"浪漫",@"红蓝",@"蓝调",@"夜色",@"黑白", nil];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 120, 320, 60)];
    if (IS_IPHONE5) {
        scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 100, 320, 60)];
    }
    scrollerView.backgroundColor = [UIColor blackColor];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollerView.showsHorizontalScrollIndicator = NO;
    scrollerView.showsVerticalScrollIndicator = NO;//关闭纵向滚动条
    scrollerView.bounces = NO;
    
    float x ;
    for(int i=0;i<14;i++)
    {
        x = 10 + 51*i;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        recognizer.delegate = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 28, 40, 23)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[arr objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setUserInteractionEnabled:YES];
        [label setTag:i];
        [label addGestureRecognizer:recognizer];
        
        [scrollerView addSubview:label];
  
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, 40, 20)];
        [bgImageView setTag:i + 1000];
        [bgImageView addGestureRecognizer:recognizer];
        [bgImageView setUserInteractionEnabled:YES];
        UIImage *bgImage = tempImage;
        bgImageView.image = bgImage;
        [scrollerView addSubview:bgImageView];
        
    }
    scrollerView.contentSize = CGSizeMake(x + 55, 50);
    
    
    
    
    
    
    [self setupFilter];
    
    [self.view addSubview:scrollerView];
    [self.view addSubview:bottnView];
    [self.view addSubview:deviceBtn];
}


- (void)setupFilter
{
    //启动相机部分
    stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    filter = [[GPUImageFilter alloc] init];
    [stillCamera addTarget:filter];
    GPUImageView *filterView = [[GPUImageView alloc]init];
    if (IS_IPHONE5) {
            [filterView setFrame:CGRectMake(0, 20, 320 , 429)];

    }else{
        [filterView setFrame:CGRectMake(0, 0, 320 , 427)];
    }
    
   
    
    //    GPUImageFilterPipeline *pipeline = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:@[filter] input:stillCamera output:filterView];
    
    [filter addTarget:filterView];
    
    [self.view addSubview:filterView];
    
    [stillCamera startCameraCapture];
}

- (IBAction)swapFrontAndBackCameras:(id)sender
{
    [stillCamera rotateCamera];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)setImageStyle:(UITapGestureRecognizer *)sender
{
    [self changeFitler:sender.view.tag];
   
}

-(void)changeFitler:(NSInteger)tag
{
    currenFilterTag = tag;
    switch (tag) {
            
        case 1000:{
            
//            filter = [[GPUImageSepiaFilter alloc] init];
            [stillCamera removeTarget:filter];
            GPUImageFilter *tempFilter = [[GPUImageFilter alloc]init];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;}
        case 1001:
        {
            //光晕
            [stillCamera removeTarget:filter];
            GPUImageGammaFilter *tempFilter = [[GPUImageGammaFilter alloc]init];
            [tempFilter setGamma:0.4f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1002:
        {
            //酒红
            [stillCamera removeTarget:filter];
            GPUImageRGBFilter *tempFilter = [[GPUImageRGBFilter alloc]init];
            [tempFilter setRed:80/255.0f];
            [tempFilter setGreen:10/255.0f];
            [tempFilter setBlue:30/255.0f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1003:
        {
            // 素描
            [stillCamera removeTarget:filter];
            GPUImageLaplacianFilter *tempFilter = [[GPUImageLaplacianFilter alloc]init];
//            [tempFilter setConvolutionKernel:newConvolutionMatrix.];
//            [tempFilter setConvolutionKernel:newConvolutionMatrix.oneway];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1004:
        {
            //哥特
            [stillCamera removeTarget:filter];
            GPUImageContrastFilter *tempFilter = [[GPUImageContrastFilter alloc]init];
            [tempFilter setContrast:0.75f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1005:
        {
            //锐色
            [stillCamera removeTarget:filter];
            GPUImageSharpenFilter *tempFilter = [[GPUImageSharpenFilter alloc]init];
            [tempFilter setSharpness:1.75f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1006:
        {
            // 类似素描
            [stillCamera removeTarget:filter];
            GPUImageCrosshatchFilter *tempFilter = [[GPUImageCrosshatchFilter alloc]init];
                [tempFilter setCrossHatchSpacing:0.01];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1007:
        {

            [stillCamera removeTarget:filter];
            GPUImageColorInvertFilter *tempFilter = [[GPUImageColorInvertFilter alloc]init];
//            [tempFilter :0.4];负片
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1008:
        {
            // 全屏马赛克
            [stillCamera removeTarget:filter];
            GPUImagePolkaDotFilter *tempFilter = [[GPUImagePolkaDotFilter alloc]init];
            [tempFilter setFractionalWidthOfAPixel:0.03];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1009:
        {
            //哥特
            [stillCamera removeTarget:filter];
            GPUImageMonochromeFilter *tempFilter = [[GPUImageMonochromeFilter alloc]init];
                   [tempFilter setColor:(GPUVector4){0.0f, 0.0f, 1.0f, 1.f}];
            [tempFilter setIntensity:0.4];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            
            break;
        }
        case 1010:
        {
            //红蓝
            [stillCamera removeTarget:filter];
            GPUImageFalseColorFilter *tempFilter = [[GPUImageFalseColorFilter alloc]init];
            //            [tempFilter setRadius:0.4];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1011:
        {
            //蓝调
            [stillCamera removeTarget:filter];
            GPUImageHueFilter *tempFilter = [[GPUImageHueFilter alloc] init];
            [tempFilter setHue:180.0f];
            
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1012:
        {
            //            //夜色
            [stillCamera removeTarget:filter];
            GPUImageBrightnessFilter *tempFilter = [[GPUImageBrightnessFilter alloc]init];
            [tempFilter setBrightness:-0.5f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        case 1013:
        {
            //黑白
            [stillCamera removeTarget:filter];
            GPUImageSaturationFilter *tempFilter = [[GPUImageSaturationFilter alloc]init];
            [tempFilter setSaturation:0.0f];
            [stillCamera addTarget:tempFilter];
            [tempFilter addTarget:filter];
            break;
        }
        default:
            break;
    }
}

- (IBAction)takePhoto:(id)sender;
{
    [photoCaptureButton setEnabled:NO];
    
    
    //    [stillCamera capturePhotoAsJPEGProcessedUpToFilter:terminalFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
//    GPUImageFilter *tempFilter = [[GPUImageFilter alloc]init];
//    [stillCamera removeTarget:filter];
//    [stillCamera addTarget:tempFilter];
//    [tempFilter addTarget:filter];
    
    [stillCamera capturePhotoAsJPEGProcessedUpToFilter:filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        // Save to assets library
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //        report_memory(@"After asset library creation");
        tempImage = [UIImage imageWithData:processedJPEG];
        self.currentImage = tempImage;
        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:stillCamera.currentCaptureMetadata completionBlock:^(NSURL *assetURL, NSError *error2)
         {
             //             report_memory(@"After writing to library");
             if (error2) {
                 NSLog(@"ERROR: the image failed to be written");
             }
             else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
                 NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                 NSString *filePath = [documentPath stringByAppendingString:@"/takenPhoto.png"];
                 NSData *imageData = [[NSData alloc]init];
                 //    aImageData = [NSKeyedArchiver archivedDataWithRootObject:aImage];
                 imageData = UIImagePNGRepresentation(tempImage);
                 [imageData writeToFile:filePath atomically:YES];
                 [ShareManager defaultManager].tempImagePath =filePath;
                 
                 
//                 NSLog(@"%@",filePath);
                 if (![Singleton instance].fromCamera) {
                     [self.delegate didFinishImage:tempImage];
                 }
                 
                 
                     [self closeView];
                 
                 
             }
			 
             runOnMainQueueWithoutDeadlocking(^{
                 //                 report_memory(@"Operation completed");
                 [photoCaptureButton setEnabled:YES];
             });
         }];
    }];
    
    
    
    
    
}

- (void)closeView
{
    [stillCamera stopCameraCapture];
    
//    [self becomeFirstResponder];
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([Singleton instance].fromCamera) {
            [self.delegate goToShare];
        }
    }];
    

}

-(void)closeNow
{
    [stillCamera stopCameraCapture];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)showPicker:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.delegate = self;
    
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];

}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:^{
        [self closeView];
        
        
        
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    tempImage = image;
    self.currentImage = image;
    
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:fullPath atomically:YES];
//    NSLog(@"%@\n",fullPath);
//    [self.delegate didFinishPickImage:fullPath];
    
    [ShareManager defaultManager].tempImagePath = fullPath;
    
    
    
    
    

//  imagePicker.currentImage = currentImage;
//    [self presentModalViewController:imagePicker animated:YES];
//    [self dismissViewControllerAnimated:YES completion:^{}];
//    [picker presentViewController:imagePicker animated:YES completion:^{}];
//    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController popToRootViewControllerAnimated:YES];
	[self dismissViewControllerAnimated:YES completion:^{}];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
