//
//  CustomTypeCell.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTypeCell;
@protocol CustomTypeCellDelegate <NSObject>

-(void)asdiohfvsalkjvhdsalkjfvbhasdjk:(CustomTypeCell *)sender;
-(void)buttonSetTouXiang:(CustomTypeCell *)sender;
-(void)buttonSetFengMian:(CustomTypeCell *)sender;
-(void)phoneIsOn:(CustomTypeCell *)sender;
-(void)messageIsOn:(CustomTypeCell *)sender;
-(void)connectIsOn:(CustomTypeCell *)sender;
- (void)setTextField;
- (void)clearCach:(UIButton *)btn;

@end

typedef NS_ENUM(NSInteger, CellType)
{
    CelldefaultType             = 1<<0,
    CellBigImageType            = 1<<1,
    CellTextFieldType           = 1<<2,
    CellAlertType               = 1<<3,
    CellMessgaeAndPhoneType     = 1<<4,
    CellConnectType             = 1<<5,
    CellClearCach               = 1<<6
};

@interface CustomTypeCell : UITableViewCell

@property (strong, nonatomic)UIButton *button;
@property (strong, nonatomic)UIButton *button1,*button2;
@property (assign, nonatomic)CellType cellType;
@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)UIImageView *userImageView;  //用户头像
@property (strong, nonatomic)UITextView       *qianmingLablel; //签名
@property (assign, nonatomic) id <CustomTypeCellDelegate>     delegate;
@property (assign, nonatomic)BOOL isOn;
@property (strong, nonatomic)UITextField * textfield;
@property (strong, nonatomic)UILabel * connectLabel;
@property (strong, nonatomic)UIImageView * connectImageView;
@property (strong, nonatomic)UILabel  *clearLabel;
@property (strong, nonatomic)UIButton  *clearBtn;


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
           cellType:(CellType)type;

- (void)refresh;
- (void)refresh2;
- (void)refresh3;
- (void)refresh4;

@end


