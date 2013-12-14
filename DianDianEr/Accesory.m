//
//  Accesory.m
//  DianDianEr
//
//  Created by Lori on 13-11-20.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "Accesory.h"

@implementation Accesory
{
    BOOL        isZoom;             //是否缩放
    NSArray     *ziTiStr;           //字体名称
}

@synthesize aTextView;
@synthesize pinBtn;
@synthesize deleteBtn;
@synthesize zoomBtn;
@synthesize startPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         //初始化界面元素
        [self initElement];
        
        //为self添加Pan手势  执行可移动或缩放的方法
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAccersory:)];
        [self addGestureRecognizer:pan];
        
        //为self添加Tap手势  当手势触摸到self 就让self可以处于编辑 其他控件显示
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAccesory:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

//移动或缩放Accersory
- (void)panAccersory:(UIPanGestureRecognizer *)sender
{
    startPoint.x = self.frame.origin.x;         //原点
    startPoint.y = self.frame.origin.y;
    static float  kX = 0;                       //移动时的距离坐标 宽
    static float  kY = 0;                       //移动时的距离坐标 高
    CGPoint currentPoint = [sender locationInView:self.superview];  //手势在self父视图中的位置

    //将zoom区域转换成自己的区域
    CGRect rect = [zoomBtn convertRect:zoomBtn.bounds fromView:zoomBtn];
    //将手势范围 判断以zoom区域为标准
    CGPoint point_pinBtn = [sender locationInView:zoomBtn];
    //手势一开始的时候就判断
    if (sender.state == UIGestureRecognizerStateBegan) {
        //如果手势在zoom区域内 就可以缩放 否则不可缩放
        if(CGRectContainsPoint(rect, point_pinBtn))
        {
            isZoom = YES;
        }
        else
        {
            isZoom = NO;
        }
    }
    
    switch (isZoom) {
        case 0:
            if (sender.state == UIGestureRecognizerStateBegan) {  //每移动一次时只最开始执行一次
                kX = currentPoint.x - startPoint.x;  //定值（当前点- 原点）   移动时保证尺寸不变
                kY = currentPoint.y - startPoint.y;
            }
            startPoint.x = currentPoint.x - kX;   //确定新原点（当前触摸点） 现在kX是定值 移动的距离就是当前的点与最先那个原点的距离
            startPoint.y = currentPoint.y - kY;
            
            //以下四步判断是为了移动出现不卡的现象
            if (startPoint.x < 0 ) {
                startPoint.x = 0;
            }
            if (self.bounds.size.width + startPoint.x > self.superview.bounds.size.width) {
                startPoint.x = self.superview.bounds.size.width - self.bounds.size.width ;
            }
            if (startPoint.y < 0 ) {
                startPoint.y = 0;
            }
            if (self.bounds.size.height + startPoint.y > self.superview.bounds.size.height) {
                startPoint.y = self.superview.bounds.size.height - self.bounds.size.height - 10;
            }
            //添加判断  不让self的frame在super的frame之外
            if (startPoint.x >= 0 && startPoint.y>= 0 && startPoint.x + self.bounds.size.width <= self.superview.bounds.size.width && startPoint.y + self.bounds.size.height <= self.superview.bounds.size.height- 10) {
                self.frame = CGRectMake(startPoint.x,startPoint.y, self.frame.size.width, self.frame.size.height);
            }
            break;
            
        case 1:
        {
            //当手势的有效点在父视图之内
            if (currentPoint.x > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
                currentPoint.x = self.superview.bounds.origin.x + self.superview.bounds.size.width - 2;
            }
            if (currentPoint.x > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
                currentPoint.y = self.superview.bounds.origin.y + self.superview.bounds.size.height -2;
            }
            
            if (currentPoint.x - startPoint.x > 60 && currentPoint.y -  startPoint.y >60) {
                self.frame = CGRectMake(startPoint.x,startPoint.y ,currentPoint.x - startPoint.x, currentPoint.y -  startPoint.y );
                aTextView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 12, self.bounds.size.width -4, self.bounds.size.height - 16);
                pinBtn.frame = CGRectMake(self.bounds.size.width/2 -12, self.bounds.origin.y - 5 , 24, 24);
                deleteBtn.frame = CGRectMake(self.bounds.origin.x +self.bounds.size.width- 16, self.bounds.origin.y+10, 18, 18);
                zoomBtn.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width -22, self.bounds.origin.y + self.bounds.size.height-22 , 18, 18);
            }
           
        }
            break;
    
        default:
            break;
    }
}
//轻拍
- (void)tapAccesory:(UIPanGestureRecognizer *)sender
{
    //当轻拍到Accesory的时候
    aTextView.editable = YES;                   //文本区域不可编辑
    aTextView.layer.borderWidth = 1;            //边框出现
    aTextView.userInteractionEnabled = YES;     //
    aTextView.layer.borderColor = [UIColor grayColor].CGColor;
    pinBtn.hidden = NO;                         //都不隐藏
    deleteBtn.hidden = NO;
    zoomBtn.hidden = NO;
}

//移除按钮组
- (void)removeAccersory
{
    [aTextView  removeFromSuperview];
    [pinBtn removeFromSuperview];
    [deleteBtn removeFromSuperview];
    [zoomBtn removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark 界面初始化 Methods
- (void)initElement
{
    //文本区域
    aTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 12, self.bounds.size.width -4, self.bounds.size.height - 16)];
     aTextView.delegate = self;
    [self addSubview:aTextView];
    //边框 背景
    aTextView.layer.borderWidth = 1.0;
    aTextView.backgroundColor = [UIColor clearColor];
    aTextView.layer.borderColor = [UIColor grayColor].CGColor;
    
    //(pin)按钮
    pinBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 -12, self.bounds.origin.y - 5 , 24, 24)];
    [pinBtn setImage:[UIImage imageNamed:@"pin"] forState:UIControlStateNormal];
    [self addSubview:pinBtn];
    
    //删除按钮
    deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.origin.x +self.bounds.size.width- 16, self.bounds.origin.y+10, 18, 18)];
    [deleteBtn addTarget:self action:@selector(removeAccersory) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    
    //缩放按钮
    zoomBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width -22, self.bounds.origin.y + self.bounds.size.height-22 , 18, 18)];
    [zoomBtn setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    [self addSubview:zoomBtn];
}

#pragma mark  UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //为aTextView添加UIToolbar  在toolbar上增加回收键盘的按钮以及四种文字样式选择的BarButtonItem
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kWIDTH_SCREEN, 22)];
    [toolbar setBackgroundImage:[UIImage imageNamed:@"NavBar_meitu_5"] forToolbarPosition:0 barMetrics:0];
    aTextView.inputAccessoryView = toolbar;
    //FZMiaoWuS-GB 方正喵呜 Kim's GirlType华康女孩  QXyingbixing硬笔行书  FZZJ-TTMBFONT方正童体毛笔
    NSArray *array = @[@"方正喵呜",@"华康女孩",@"硬笔行书",@"童体毛笔",@"收回键盘"];
    ziTiStr = @[@"FZMiaoWuS-GB",@"Kim's GirlType",@"QXyingbixing",@"FZZJ-TTMBFONT",@"FZMiaoWuS-GB"];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    for (int i = 0; i< 5; i++) {
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWIDTH_SCREEN/6, 22)];
        button.titleLabel.font = [UIFont fontWithName:[ziTiStr objectAtIndex:i] size:12];
        [self.delegate setTextViewBoardFontColor:self button:button];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        UIBarButtonItem  * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(textViewBoard:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [buttons addObject:barButtonItem];
    }
    [toolbar setItems:buttons];
    aTextView.inputAccessoryView = toolbar;
    
    [self.delegate setTextViewFontColor:self];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.35f delay:0.35f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //当编辑完成时
        aTextView.editable = NO;                    //文本区域不可编辑
        aTextView.userInteractionEnabled = NO;      //不可交互
        aTextView.layer.borderWidth = 0;            //边框消失
        pinBtn.hidden = YES;                        //其他控件隐藏
        deleteBtn.hidden = YES;
        zoomBtn.hidden = YES;
    } completion:^(BOOL finished) {

    }];
    return YES;
}

//键盘上的相关方法
- (void)textViewBoard:(UIButton *)button
{
    switch (button.tag) {
        case 4:
            [aTextView resignFirstResponder];
            break;
        default: [self.delegate setTextViewFont:self index:button.tag];
            break;
    }
}




@end
