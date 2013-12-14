//
//  CustomTypeCell.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "CustomTypeCell.h"


@implementation CustomTypeCell
{
    UILabel * alertLabel;
    UIButton *messge;
    UIButton *phone;
    UIButton *connect;
    UIImageView * connectImageView;
}

@synthesize isOn;
@synthesize cellType;
@synthesize imageView;
@synthesize userImageView;
@synthesize qianmingLablel;
@synthesize button1;
@synthesize button2;
@synthesize delegate;
@synthesize connectLabel;
@synthesize connectImageView;
@synthesize textfield;


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           cellType:(CellType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        switch (type)
        {
            case CelldefaultType:
            {
                self.button = [UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:self.button];                
                break;
            }
            case CellBigImageType:
            {
//                imageView = [[UIImageView alloc] init];
//                imageView.image = [UIImage imageNamed:@"BG"];
//                [self addSubview:imageView];
                
                userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
                userImageView.image = [UIImage imageNamed:@"Retina-Home-Screen---114px"];
                [self addSubview:userImageView];
                
//                qianmingLablel = [[UITextView alloc] initWithFrame:CGRectMake(82, 10, self.frame.size.width - 72 - 30, 60)];
//                qianmingLablel.backgroundColor = [UIColor grayColor];
//                qianmingLablel.layer.borderWidth = 2.0f;
//                           
//                [self addSubview:qianmingLablel];
                
                button1 = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 88,20)];
                button1.center = self.center;
                [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                button2 = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80 -88, qianmingLablel.frame.origin.y + qianmingLablel.frame.size.height, 88,20)];
                [button1 setTitle:@"设置头像" forState:UIControlStateNormal];
//                [button2 setTitle:@"设置封面" forState:UIControlStateNormal];
                [self addSubview:button1];
//                [imageView addSubview:button2];
                break;
            }
            case CellAlertType:
            {
                alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,100, 20)];
                [self addSubview:alertLabel];
                break;
            }
            case CellTextFieldType:
            {
                textfield = [[UITextField alloc] init];
                textfield.frame = CGRectMake(20, 10, 150, 20);
                textfield.delegate = (id)self;
                [self addSubview:textfield];
                break;
            }
            case CellMessgaeAndPhoneType:
            {
                phone = [[UIButton alloc] initWithFrame:CGRectMake( self.bounds.size.width - 40, 10, 20, 20)];
                messge = [[UIButton alloc] initWithFrame:CGRectMake( self.bounds.size.width - 70, 10, 20, 20)];
                [self addSubview:messge];
                [self addSubview:phone];
         
               break;
            }
            case CellConnectType:
            {
                connectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
                [self addSubview:connectImageView];
                connectLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 100, 20)];
                connectLabel.backgroundColor = [UIColor clearColor];
                [self addSubview: connectLabel];
                connect = [[UIButton alloc] initWithFrame:CGRectMake( self.bounds.size.width - 60, 10, 60, 20)];
                [self addSubview:connect];
            
                break;
            }
            case CellClearCach:
            {
         
                _clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
                _clearLabel.backgroundColor = [UIColor clearColor];
                [self addSubview:_clearLabel];
             
                _clearBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [_clearBtn setFrame:CGRectMake( self.bounds.size.width - 80, 10, 60, 20)];
                [self addSubview:_clearBtn];
        
                [_clearBtn setTitle:@"开始清理" forState:UIControlStateNormal];
                _clearBtn.titleLabel.font = [UIFont fontWithName:@"Optima" size:14];

                _clearBtn.backgroundColor = [UIColor clearColor];
                [_clearBtn addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
                
            default:
                break;
        }
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
     userImageView.image = [UIImage imageNamed:@"Retina-Home-Screen---114px"];
    self.button.frame = CGRectMake(self.bounds.size.width - 40, 10, 20, 20);
    [self.button addTarget:self action:@selector(buttonIsOn) forControlEvents:UIControlEventTouchUpInside];
    
    imageView.frame = CGRectMake(0,0, self.bounds.size.width - 30, self.bounds.size.height- 10);
    imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    imageView.userInteractionEnabled = YES;
 
    [self.button1 addTarget:self action:@selector(buttonSet1) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(buttonSet2) forControlEvents:UIControlEventTouchUpInside];
    [phone addTarget:self action:@selector(buttonIsOn2) forControlEvents:UIControlEventTouchUpInside];
    [messge addTarget:self action:@selector(buttonIsOn3) forControlEvents:UIControlEventTouchUpInside];

    [connect addTarget:self action:@selector(buttonIsOn4) forControlEvents:UIControlEventTouchUpInside];
  
}

-(void)refresh
{
    switch (self.isOn) {
        case YES:
        {
            [self.button setImage:[UIImage imageNamed:@"bg-menuitem-highlighted@2x"] forState:UIControlStateNormal];
            break;
        }
        case NO:
        {
            [self.button setImage:[UIImage imageNamed:@"bg-addbutton@2x"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

-(void)refresh2
{
    switch (self.isOn) {
        case YES:
        {
            [phone setImage:[UIImage imageNamed:@"bg-menuitem-highlighted@2x"] forState:UIControlStateNormal];
            break;
        }
        case NO:
        {
            
            [phone setImage:[UIImage imageNamed:@"bg-addbutton@2x"] forState:UIControlStateNormal];
            
            break;
        }
        default:
            break;
    }
}
-(void)refresh3
{
    switch (self.isOn) {
        case YES:
        {
            [messge setImage:[UIImage imageNamed:@"bg-menuitem-highlighted@2x"] forState:UIControlStateNormal];
            break;
        }
        case NO:
        {
            [messge setImage:[UIImage imageNamed:@"bg-addbutton@2x"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}
-(void)refresh4
{
    switch (self.isOn) {
        case YES:
        {
            [connect setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
            break;
        }
        case NO:
        {
            [connect setImage:[UIImage imageNamed:@"redo"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}
-(void)buttonSet1//设置头像
{

    [self.delegate buttonSetTouXiang:self];
}
-(void)buttonSet2//设置封面
{
    [self.delegate buttonSetFengMian:self];
}

-(void)buttonIsOn//开关
{
    self.isOn = !self.isOn;
    [self.delegate asdiohfvsalkjvhdsalkjfvbhasdjk:self];
}
-(void)buttonIsOn2//电话状态
{
    self.isOn = !self.isOn;
    [self.delegate phoneIsOn:self];
}
-(void)buttonIsOn3//信息状态
{
    self.isOn = !self.isOn;
    [self.delegate messageIsOn:self];
}
-(void)buttonIsOn4//连接状态
{
    self.isOn = !self.isOn;
    [self.delegate connectIsOn:self];
}

- (void)clear:(UIButton *)btn
{
    [delegate clearCach:btn];
}

@end
