//
//  SuggestView.h
//  DianDianEr
//
//  Created by Lori on 13-11-29.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestView : UIView<UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic, strong)UITextView  *aTextView;
@property(nonatomic, strong)UITextField *aTextField;
@property(nonatomic, strong)UILabel     *aLabel;
@property(nonatomic, strong)UILabel     *qLabel;



@end
