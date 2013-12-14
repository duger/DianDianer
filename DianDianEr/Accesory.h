//
//  Accesory.h
//  DianDianEr
//
//  Created by Lori on 13-11-20.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Accesory;
@protocol AccesoryDelegate <NSObject>

//设置TextView的字体及字体大小
- (void)setTextViewFont:(Accesory *)aAccesory index:(int)index;
//设置TextView的字体颜色
- (void)setTextViewFontColor:(Accesory *)aAccesory;
//设置TextView键盘字体的颜色
- (void)setTextViewBoardFontColor:(Accesory *)aAccesory button:(UIButton *)button;

@end

@interface Accesory : UIButton <UITextViewDelegate>
{
    
}

@property(nonatomic,strong) UITextView *aTextView;      //TextView文本区域

@property(nonatomic,strong) UIButton *pinBtn;           //Pin按钮
@property(nonatomic,strong) UIButton *deleteBtn;        //删除按钮
@property(nonatomic,strong) UIButton *zoomBtn;          //缩放按钮

@property(nonatomic,assign) CGPoint startPoint;         //self的原点

@property(nonatomic,assign) id<AccesoryDelegate>  delegate;

@end
