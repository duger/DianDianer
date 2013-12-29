//
//  TuYaViewController.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-22.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDrawingView.h"
#import "Accesory.h"
#import "ImageCropperView.h"

@protocol  TuYaViewControllerDelegate<NSObject>
@optional
-(void)didFinishTuYa;
-(void)tuYaGoToShare;
@end
@interface TuYaViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ACEDrawingViewDelegate,UIAlertViewDelegate,AccesoryDelegate>
@property (weak,nonatomic) id <TuYaViewControllerDelegate>delegate;
@property(strong, nonatomic)ACEDrawingView      *aPainterView;      //画板
@property(strong, nonatomic)UIImage             *aImage;            //绘制的图片
@property(strong, nonatomic)NSData              *aImageData;        //绘制的图片

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

@property (strong, nonatomic) IBOutlet ImageCropperView *imageCropperView;  //要裁剪的图片视图
@property (strong, nonatomic) IBOutlet UIView           *background;
@property (strong, nonatomic) IBOutlet UIButton         *cancel;
@property (strong, nonatomic) IBOutlet UIButton         *ok;

- (IBAction)changebackround:(UIButton *)sender;
- (IBAction)clear:(UIButton *)sender;
- (IBAction)redo:(UIButton *)sender;
- (IBAction)undo:(UIButton *)sender;
- (IBAction)save:(UIButton *)sender;


- (IBAction)didClickBack:(UIBarButtonItem *)sender;
- (IBAction)didClickShare:(UIBarButtonItem *)sender;

@end
