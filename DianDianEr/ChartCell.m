//
//  ChartCell.m
//  DianDianEr
//
//  Created by Duger on 13-10-24.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "ChartCell.h"

@implementation ChartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //        [self prepareForReuse];
        //        self.kContentView = [[UIView alloc]init];
        //        self.chartTextField = [[UITextField alloc]init];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    
    
}

@end
