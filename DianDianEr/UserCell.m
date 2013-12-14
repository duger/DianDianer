//
//  UserCell.m
//  DianDianEr
//
//  Created by 王超 on 13-11-13.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell
{
    NCMusicEngine *_player;
}
@synthesize isGoodorNot;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.playButton = [[Mp3PlayerButton alloc]initWithFrame:CGRectMake(self.mainView.bounds.origin.x+90, self.mainView.bounds.origin.y-5, 30, 30)];
    [self.mainView addSubview:self.playButton];
    isGoodorNot = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mainView.frame = CGRectMake(10, self.bounds.size.height - 30, 222, 19);
    self.shareImage.frame = CGRectMake(10, self.bounds.size.height-110, 70, 70);
    if (!isGoodorNot) {
        self.goodButton.imageView.image = [UIImage imageNamed:@"good.png"];
    }else{
        self.goodButton.imageView.image = [UIImage imageNamed:@"goodhightlight.png"];
    }
    
}

@end
