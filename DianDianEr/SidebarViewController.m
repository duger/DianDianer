//
//  ViewController.m
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import "SidebarViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "FirstViewController.h"

@interface SidebarViewController ()
{
    UIViewController  *_currentMainController;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}
@property (strong,nonatomic)FirstViewController *firstVC;
@property (strong,nonatomic)LeftSideBarViewController *leftSideBarViewController;
@property (strong,nonatomic)RightSideBarViewController *rightSideBarViewController;

@end

@implementation SidebarViewController
@synthesize leftSideBarViewController,rightSideBarViewController,contentView,navBackView;


static SidebarViewController *rootViewCon;
const int ContentOffset=285;
const int ContentMinOffset=80;
const float MoveAnimationDuration = 0.35;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

+ (id)share
{
    return rootViewCon;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (rootViewCon) {
        rootViewCon = nil;
    }
	rootViewCon = self;
    
    sideBarShowing = NO;
    currentTranslate = 0;
    
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 1;
    self.contentView.backgroundColor = [UIColor clearColor];


    self.leftSideBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftSideBarViewController"];
    self.leftSideBarViewController.delegate = self;
    [self.leftSideBarViewController.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic2.png"]]];
    self.rightSideBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideBarViewController"];
    
    [self addChildViewController:self.leftSideBarViewController];
    [self addChildViewController:self.rightSideBarViewController];
    self.leftSideBarViewController.view.frame = self.navBackView.bounds;
    self.rightSideBarViewController.view.frame = self.navBackView.bounds;
    [self.navBackView addSubview:self.leftSideBarViewController.view];
    [self.navBackView addSubview:self.rightSideBarViewController.view];
    [self.leftSideBarViewController.view setFrame:CGRectMake(0, 20, 320, ScreenHeight)];
    [self.rightSideBarViewController.view setFrame:CGRectMake(0, 20, 320, self.view.bounds.size.height - 20)];

    self.navBackView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic.png"]];
    _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    [self.contentView addGestureRecognizer:_panGestureReconginzer];
    if (IS_IPHONE5) {
        [self.contentView setFrame:CGRectMake(0, 20, 320, ScreenHeight)];
//        [self.navBackView setFrame:CGRectMake(0, 0, 320, ScreenHeight)];
//        [self.thirdView setFrame:CGRectMake(0, 20, 320, ScreenHeight)];
    }else{
        [self.contentView setFrame:CGRectMake(0, 0, 320, ScreenHeight)];
//        [self.navBackView setFrame:CGRectMake(0, 0, 320, ScreenHeight)];
//        [self.thirdView setFrame:CGRectMake(0, 0, 320, ScreenHeight)];
    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)contentViewAddTapGestures
{
    if (_tapGestureRecognizer) {
        [self.contentView   removeGestureRecognizer:_tapGestureRecognizer];
        _tapGestureRecognizer = nil;
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapOnContentView:)];
    [self.contentView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)tapOnContentView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
}

- (void)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{
//    if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
//    {
//        CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
//        if (translation >100) {
//            
//            [self showSideBarControllerWithDirection:SideBarShowDirectionLeft];
//        }
//        else if (translation < -100) {
//            
//            [self showSideBarControllerWithDirection:SideBarShowDirectionNone];
//        }
//	}
    if (panGestureReconginzer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
        self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
        UIView *view ;
        if (translation+currentTranslate>0)
        {
            view = self.leftSideBarViewController.view;
        }else
        {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
    {
		currentTranslate = self.contentView.transform.tx;
        if (!sideBarShowing) {
            if (fabs(currentTranslate)<ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
            }else if(currentTranslate>ContentMinOffset)
            {
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }else
        {
            if (fabs(currentTranslate)<ContentOffset-ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
                
            }else if(currentTranslate>ContentOffset-ContentMinOffset)
            {
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }
        
        
	}

  
   
}

#pragma mark - nav con delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count]>1) {
        [self removepanGestureReconginzerWhileNavConPushed:YES];
    }else
    {
        [self removepanGestureReconginzerWhileNavConPushed:NO];
    }

}

- (void)removepanGestureReconginzerWhileNavConPushed:(BOOL)push
{
    if (push) {
        if (_panGestureReconginzer) {
            [self.contentView removeGestureRecognizer:_panGestureReconginzer];
            _panGestureReconginzer = nil;
        }
    }else
    {
        if (!_panGestureReconginzer) {
            _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
            [self.contentView addGestureRecognizer:_panGestureReconginzer];
        }
    }
}
#pragma mark - side bar select delegate
- (void)leftSideBarSelectWithController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller setDelegate:self];
    }
    if (_currentMainController == nil) {
		controller.view.frame = self.contentView.bounds;
		_currentMainController = controller;
		[self addChildViewController:_currentMainController];
		[self.contentView addSubview:_currentMainController.view];
		[_currentMainController didMoveToParentViewController:self];
	} else if (_currentMainController != controller && controller !=nil) {
		controller.view.frame = self.contentView.bounds;
		[_currentMainController willMoveToParentViewController:nil];
		[self addChildViewController:controller];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_currentMainController
						  toViewController:controller
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_currentMainController removeFromParentViewController];
									[controller didMoveToParentViewController:self];
									_currentMainController = controller;
								}
         ];
	}
    
    [self showSideBarControllerWithDirection:SideBarShowDirectionNone];
}


- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    
//    if (direction!=SideBarShowDirectionNone) {
//        UIView *view ;
//        
//            view = self.leftSideBarViewController.view;
//        
//        [self.navBackView bringSubviewToFront:view];
//    }
//    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];
    if (direction!=SideBarShowDirectionNone) {
        UIView *view ;
        if (direction == SideBarShowDirectionLeft)
        {
            view = self.leftSideBarViewController.view;
        }else
        {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];

}



#pragma animation


/*- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
           
            if (_tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:_tapGestureRecognizer];
                _tapGestureRecognizer = nil;
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
             sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:animations completion:complete];
}
 */

- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            case SideBarShowDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-ContentOffset, 0);
            }
                break;
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
            
            if (_tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:_tapGestureRecognizer];
                _tapGestureRecognizer = nil;
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
            sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:animations completion:complete];
}


@end
