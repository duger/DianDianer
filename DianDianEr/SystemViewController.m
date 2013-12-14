//
//  SystemViewController.m
//  DianDianEr
//
//  Created by 王超 on 13-10-21.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "SystemViewController.h"
#import "SuggestView.h"



@interface SystemViewController ()
{
    UILabel *lable;
    UITableView     *aTableView;
    FTCoreTextView  *aboutView;
    SuggestView     *suggestView;

    
}

@end

@implementation SystemViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}
- (NSString *)textForAboutView
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"aboutText" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}
- (NSString *)textForSuggestView
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"suggestText" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}

- (NSArray *)coreTextStyle
{
    NSMutableArray *result = [NSMutableArray array];
    
    FTCoreTextStyle *imageStyle = [FTCoreTextStyle new];
	imageStyle.paragraphInset = UIEdgeInsetsMake(0,0,0,0);
	imageStyle.name = FTCoreTextTagImage;
	imageStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:imageStyle];
    
    FTCoreTextStyle *row =[FTCoreTextStyle new];
    row.name = @"row";
    row.font = [UIFont fontWithName:@"FZMiaoWuS-GB" size:20];
    row.textAlignment = 2;
    row.color = [UIColor redColor];
    [result addObject:row];
    
    FTCoreTextStyle *row1 =[FTCoreTextStyle new];
    row1.name = @"row1";
    row1.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
    row1.color = [UIColor blueColor];
    [result addObject:row1];
    
    FTCoreTextStyle *row2 =[FTCoreTextStyle new];
    row2.name = @"row2";
    row2.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
    row2.textAlignment = 2;
    [result addObject:row2];
    
    FTCoreTextStyle *linkStyle =[FTCoreTextStyle new];
    linkStyle.name = FTCoreTextTagLink;
    linkStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
    linkStyle.color = [UIColor greenColor];
    linkStyle.textAlignment = 2;
    [result addObject:linkStyle];
    
    FTCoreTextStyle *linkStyle2 =[FTCoreTextStyle new];
    linkStyle2.name = @"_link2";
    linkStyle2.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:14];
    [result addObject:linkStyle2];
    
    FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	defaultStyle.textAlignment = FTCoreTextAlignementJustified;
	[result addObject:defaultStyle];
    
    FTCoreTextStyle *italicStyle = [defaultStyle copy];
	italicStyle.name = @"italic";
	italicStyle.underlined = YES;
    italicStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:16.f];
	[result addObject:italicStyle];
    
    FTCoreTextStyle *boldStyle = [defaultStyle copy];
	boldStyle.name = @"bold";
    boldStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:16.f];
	[result addObject:boldStyle];
    
    return  result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320, 44);
    }else{
        self.topView.frame = CGRectMake(0, 0, 320, 44);
    }
    aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60) style:UITableViewStyleGrouped];
    [self.view addSubview:aTableView];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    
    aboutView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN - 60,kHEIGHT_SCREEN - 60)];
    [self.view addSubview:aboutView];
    aboutView.backgroundColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:1];
    [aboutView setText:[self textForAboutView]];
    [aboutView addStyles:[self coreTextStyle]];
    [aboutView setDelegate:self];
 
    
    suggestView = [[SuggestView alloc] initWithFrame:CGRectMake(kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN - 60,kHEIGHT_SCREEN - 60)];
    [self.view addSubview:suggestView];
    suggestView.backgroundColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:1];
    
    
    

}
#pragma mark FTCoreTextViewDelegate
- (void)coreTextView:(FTCoreTextView *)coreTextView receivedTouchOnData:(NSDictionary *)data;
{
    CGRect frame = CGRectFromString([data objectForKey:FTCoreTextDataFrame]);
    
    if (CGRectEqualToRect(CGRectZero, frame)) return;
    
    frame.origin.x -= 3;
    frame.origin.y -= 1;
    frame.size.width += 6;
    frame.size.height += 6;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:3];
    [view setBackgroundColor:[UIColor orangeColor]];
    [view setAlpha:0];
    [aboutView.superview addSubview:view];
    [UIView animateWithDuration:0.2 animations:^{
        [view setAlpha:0.4];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [view setAlpha:0];
        }];
    }];
    
    return;
    
    NSURL *url = [data objectForKey:FTCoreTextDataURL];
    if (!url) return;
    [[UIApplication sharedApplication] openURL:url];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView Datesource方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
            
        default: return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier_section_3 = @"systemStyle";//系统
    static NSString *cellIdentifier_section_4 = @"cellIdentifier_section_4";//清理缓存
    CustomTypeCell * cell = nil;
    switch (indexPath.section)
    {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_4];
            if (cell == nil)
            {
                cell = [[CustomTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_4 cellType:CellClearCach];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.clearLabel.text = @"清理缓存";
            cell.clearBtn.tag = 100;
            cell.clearLabel.font = [UIFont fontWithName:@"Optima" size:16];
            [cell     setDelegate:self];
        }
            break;

        case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier_section_3];
                if (cell == nil)
                {
                    cell = (CustomTypeCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_section_3];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                NSArray * array = @[@"关于",@"意见反馈"];
                cell.textLabel.textAlignment = 1;
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = [UIFont fontWithName:@"Optima" size:16.0];
            }
            break;
        
    }
     return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray * array = @[@"缓存",@""];
    NSString * title = [array objectAtIndex:section];
    return title;
}


#pragma mark TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && aTableView.frame.origin.x >= 0) {
        switch (indexPath.row) {
            case 0:
            {
                [UIView animateWithDuration:0.35 animations:^{
                    aTableView.frame = CGRectMake(60 - kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
                    aboutView.frame = CGRectMake(60, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN - 60,kHEIGHT_SCREEN - 60);
                } completion:^(BOOL finished) {
                    ;
                }];
                break;
            }
          case 1:
            {
                [UIView animateWithDuration:0.35 animations:^{
                    aTableView.frame = CGRectMake(60 - kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
                    suggestView.frame = CGRectMake(60, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN - 60,kHEIGHT_SCREEN - 60);
                } completion:^(BOOL finished) {
                    ;
                }];
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)viewDidUnload {
    [self setTopView:nil];
    [super viewDidUnload];
}

CGPoint previous;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    previous = [[[touches allObjects] lastObject] previousLocationInView:self.view];

}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint current = [[[touches allObjects] lastObject] locationInView:self.view];
    NSLog(@"%f %f",previous.x,current.x);
    if (CGRectContainsPoint(aboutView.frame, previous) && current.x > previous.x) {
        [UIView animateWithDuration:0.35 animations:^{
            aboutView.frame = CGRectMake(kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height, kWIDTH_SCREEN -60, kHEIGHT_SCREEN - self.topView.frame.origin.y+self.topView.frame.size.height);
            aTableView.frame = CGRectMake(self.topView.frame.origin.x, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
        } completion:^(BOOL finished) {
            ;
        }];
    }
    else if(CGRectContainsPoint(suggestView.frame, previous) && current.x > previous.x)
    {
        [UIView animateWithDuration:0.35 animations:^{
            aTableView.frame = CGRectMake(self.topView.frame.origin.x, self.topView.frame.origin.y+self.topView.frame.size.height,kWIDTH_SCREEN,kHEIGHT_SCREEN - 60);
            suggestView.frame = CGRectMake(kWIDTH_SCREEN, self.topView.frame.origin.y+self.topView.frame.size.height, kWIDTH_SCREEN -60, kHEIGHT_SCREEN - self.topView.frame.origin.y+self.topView.frame.size.height);
        } completion:^(BOOL finished) {
            ;
        }];
    }
}

-(void)clearCach:(UIButton *)btn
{
    [btn setTitle:@"清理中..." forState:UIControlStateNormal];
    NSArray *tempArray = [[DiandianCoreDataManager shareDiandianCoreDataManager] all_share];
    for (NSManagedObject *object  in tempArray) {
        [[DiandianCoreDataManager shareDiandianCoreDataManager] delete_a_share:object];
    };
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(removeSQL) userInfo:nil repeats:NO];
}
- (void)removeSQL
{
    UIButton * btn = (UIButton *)[self.view viewWithTag:100];
    [btn setTitle:@"已清空" forState:UIControlStateNormal];
}
- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//
//-(void)asdiohfvsalkjvhdsalkjfvbhasdjk:(CustomTypeCell *)sender
//{
//    NSLog(@"开关状态口%@",sender);
//    [sender refresh];
//}
//
//-(void)phoneIsOn:(CustomTypeCell *)sender
//{
//    NSLog(@"电话状态%@",sender);
//    [sender refresh2];
//    
//}
//-(void)messageIsOn:(CustomTypeCell *)sender
//{
//    NSLog(@"消息状态%@",sender);
//    [sender refresh3];
//}
//-(void)connectIsOn:(CustomTypeCell *)sender
//{
//    NSLog(@"连接状态%@",sender);
//    
//    [sender refresh4];
//}

@end
