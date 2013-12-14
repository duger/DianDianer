//
//  AwesomeMenu.h
//  DianDianEr
//
//  Created by 王超 on 13-10-20.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenuItem.h"

@protocol AwesomeMenuDelegate;


@interface AwesomeMenu : UIView <AwesomeMenuItemDelegate>

@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, weak) id<AwesomeMenuDelegate> delegate;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat animationDuration;

- (id)initWithFrame:(CGRect)frame startItem:(AwesomeMenuItem*)startItem optionMenus:(NSArray *)aMenusArray;

@end

@protocol AwesomeMenuDelegate <NSObject>
- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx;
@optional
- (void)awesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu;
- (void)awesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu;
@end

