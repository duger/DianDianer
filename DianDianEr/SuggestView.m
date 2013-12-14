//
//  SuggestView.m
//  DianDianEr
//
//  Created by Lori on 13-11-29.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "SuggestView.h"
#import "UIColor+Random.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"

@implementation SuggestView
{
    UILabel *alertLabel;
    MMProgressHUD   *progressHUD;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 80, 20)];
        label.text = @"意见反馈";
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60, 8, 50, 22)];
        [button setTitle:@"发送" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor customBlack] forState:UIControlStateNormal];
         [button setTitleColor:[UIColor customBlue] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:button];
        [button addTarget:self action:@selector(didClickSend:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.aTextView = [[UITextView alloc] initWithFrame:CGRectMake(12, 30, self.bounds.size.width - 24, 110)];
        self.aTextView.backgroundColor = [UIColor clearColor];
        self.aTextView.layer.borderWidth = 1.0f;
        self.aTextView.layer.borderColor = [UIColor customCayn].CGColor;
        self.aTextView.delegate = self;
        [self addSubview:self.aTextView];
        
        self.aTextField = [[UITextField alloc] initWithFrame:CGRectMake(12,self.aTextView.frame.origin.y + self.aTextView.frame.size.height + 5,self. bounds.size.width - 24, 22)];
        self.aTextField.backgroundColor = [UIColor clearColor];
        self.aTextField.layer.borderWidth = 1.0f;
        self.aTextField.layer.borderColor = [UIColor customCayn].CGColor;
        self.aTextField.delegate = self;
        self.aTextField.placeholder = @"邮箱/QQ/手机号";
        self.aTextField.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:self.aTextField];
        
        self.aLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.aTextView.bounds.size.width - 60, self.aTextView.bounds.size.height +10, 80, 10)];
        self.aLabel.backgroundColor = [UIColor clearColor];
        self.aLabel.textAlignment = 1;
        self.aLabel.font = [UIFont systemFontOfSize:12.0f];
        self.aLabel.text = @"0/140";
        [self addSubview:self.aLabel];
        
        self.qLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, self.aTextField.frame.origin.y+ self.aTextField.frame.size.height + 3, self. bounds.size.width - 24, 22)];
        self.qLabel.text = @"您也可以加入我们的QQ群:121143472";
        self.qLabel.backgroundColor = [UIColor clearColor];
        self.qLabel.font = [UIFont systemFontOfSize:12.0f];
        self.qLabel.textColor = [UIColor blueColor];
        self.qLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.qLabel];
        
        alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, kWIDTH_SCREEN, 30)];
        label.backgroundColor = [UIColor clearColor];
        alertLabel.backgroundColor = [UIColor clearColor];
        alertLabel.alpha = 0;
        [self addSubview:alertLabel];
        alertLabel.text = @"发送成功,非常感谢您对我们的支持";
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.aTextView action:@selector(resignFirstResponder)];
        [tap addTarget:self.aTextField action:@selector(resignFirstResponder)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = 140 -[new length];
    if (res > 140 ) {
        res = 140;
    }
            if(res >= 0){
                self.aLabel.text = [NSString stringWithFormat:@"%d/140",[new length]];
                return YES;
            }
            else{
                NSRange rg = {0,[text length]+res};
                if (rg.length>0) {
                    NSString *s = [text substringWithRange:rg];
                    [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
                    self.aLabel.text = [NSString stringWithFormat:@"%d/140",[new length]];
                }
                return NO;
    }
        return YES;
 
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField resignFirstResponder]) {
        return YES;
    }
    return NO;
}

- (void)didClickSend:(UIButton *)sender
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:@"正在发送!"];
    [self performSelector:@selector(isConectedOrNot:) withObject:nil afterDelay:2.0f];
}

- (void)isConectedOrNot:(id)sender
{
    [MMProgressHUD dismissWithSuccess:@"发送成功!"];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [textView clearsContextBeforeDrawing];
//    [textView clearsOnInsertion];
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
