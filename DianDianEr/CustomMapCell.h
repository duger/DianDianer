//
//  CustomMapCell.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomMapDelegate <NSObject>
@optional
-(void)buttonChange1:(UIButton *)btn;
-(void)buttonChange2:(UIButton *)btn;


@end


@interface CustomMapCell : UITableViewCell 

@property (strong, nonatomic) IBOutlet UILabel *chageTitle;
@property (strong, nonatomic) IBOutlet UILabel *changeSubtitle;



@property (strong, nonatomic) IBOutlet UIImageView *aImageView;

@property (strong, nonatomic) IBOutlet UIButton *bt1;
@property (strong, nonatomic) IBOutlet UIButton *bt2;


@property(assign, nonatomic)id<CustomMapDelegate> delegate;

- (IBAction)bt1:(UIButton *)sender;
- (IBAction)bt2:(UIButton *)sender;



@end


