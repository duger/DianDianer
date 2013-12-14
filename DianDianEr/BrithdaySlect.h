//
//  BrithdaySlect.h
//  DianDianEr
//
//  Created by 信徒 on 13-11-4.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BrithdaySlectDelegate;

@interface BrithdaySlect : UIView
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;

@property (assign, nonatomic) id<BrithdaySlectDelegate> delegate;

- (IBAction)selectDate:(UIButton *)sender;


@end
@protocol BrithdaySlectDelegate <NSObject>

@optional
- (void)selectBrithday:(UIButton *)btn;

@end