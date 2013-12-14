//
//  PopInfoCell.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PopInfoDelegate;
@interface PopInfoCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;

@property (assign, nonatomic) id<PopInfoDelegate> delegate;

- (IBAction)btn1:(id)sender;
- (IBAction)btn2:(id)sender;


@end
@protocol PopInfoDelegate <NSObject>

@optional
- (void)bt1;
- (void)bt2;

@end