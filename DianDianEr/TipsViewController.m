//
//  TipsViewController.m
//  DianDianEr
//
//  Created by Duger on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "TipsViewController.h"

@interface TipsViewController ()

@end

@implementation TipsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
            }
    return self;
}

-(void)awakeFromNib
{
    self.title = @"地图";
    self.view.backgroundColor = [UIColor lightGrayColor];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSString *)tabImageName
{
	return @"image-3";
}

- (NSString *)tabTitle
{
	return self.title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
