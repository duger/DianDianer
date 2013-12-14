//
//  HomePageCell.m
//  DianDianEr
//
//  Created by 王超 on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "HomePageCell.h"
#import "CommentViewController.h"
#import "Change.h"

@implementation HomePageCell
{
    NCMusicEngine *_player;
}
@synthesize isGoodorNot;
@synthesize shareLabel;

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
    self.playButton = [[Mp3PlayerButton alloc]initWithFrame:CGRectMake(self.mainView.bounds.origin.x+80, self.mainView.bounds.origin.y-3, 30, 30)];
    [self.mainView addSubview:self.playButton];
    isGoodorNot = NO;
    
    
    //        CGSize labelsize = [text sizeWithFont:[UIFont fontWithName:@"Arial" size:16.0f] constrainedToSize:max lineBreakMode:NSLineBreakByWordWrapping];
    
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mainView.frame = CGRectMake(10, self.bounds.size.height - 30, 300, 38);
    self.shareImage.frame = CGRectMake(10, self.bounds.size.height-110, 70, 70);
    if (!isGoodorNot) {
        self.goodButton.imageView.image = [UIImage imageNamed:@"good.png"];
    }else{
        self.goodButton.imageView.image = [UIImage imageNamed:@"goodhightlight.png"];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (IBAction)didClickGood:(UIButton *)sender {
    isGoodorNot = !isGoodorNot;
    if (!isGoodorNot) {
        sender.imageView.image = [UIImage imageNamed:@"good.png"];
    }else{
        sender.imageView.image = [UIImage imageNamed:@"goodhightlight.png"];
    }
    [(UITableView *)self.nextResponder.nextResponder reloadData];
//    NSLog(@"%@",self.nextResponder.nextResponder.class);

    
}

-(CGRect)thegetShareLabelSize:(Share *)share
{
    

    CGSize max = CGSizeMake(300, 1000.0f);
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:share.s_content];
    self.shareLabel.attributedText = attributedString;
    NSRange range = NSMakeRange(0, attributedString.length);
    NSDictionary *dic = [attributedString attributesAtIndex:0 effectiveRange:&range];
    CGRect labelSize = [self.shareLabel.text boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil];
    //    CGRect labelsize = [attributedString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    labelSize.size.height *= 2;
    //    [shareLabel setFrame:labelsize];
    return labelSize;
}

@end
