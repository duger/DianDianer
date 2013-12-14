//
//  CameraViewController.h
//  DiandianerCamera
//
//  Created by Duger on 13-10-18.
//  Copyright (c) 2013年 Duger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
@protocol CameraViewControllerDelegate <NSObject>
-(void)didFinishPickImage:(NSString *)imagePath;
-(void)goToShare;
-(void)didFinishImage:(UIImage *)CurrentImage;
@end

@interface CameraViewController : UIViewController<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter;
    UIButton *photoCaptureButton;
    UIScrollView *scrollerView;
    UIImage *tempImage;
    NSInteger currenFilterTag;
}

+(CameraViewController *)instence;

@property(nonatomic,assign) id<CameraViewControllerDelegate>delegate;
@property(nonatomic,retain) UIImage *currentImage;
@end
