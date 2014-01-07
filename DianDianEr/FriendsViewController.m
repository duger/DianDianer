//
//  FriendsViewController.m
//  DianDianEr
//
//  Created by Duger on 13-10-23.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "FriendsViewController.h"
#import "ChartViewController.h"
#import "XMPPManager.h"
#import "FriendCell.h"
#import "DDLog.h"

@interface FriendsViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation FriendsViewController
{
    UITextField *newFriend;
}

@synthesize fetchedResultsController;



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
    [super awakeFromNib];
    self.title = @"好友";
    self.friendsList = [[NSMutableArray alloc]init];
  
    self.fetchedResultsController = [XMPPManager instence].XMPPRosterFetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //注册自定义tableCell
    [self.friendsTableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FriendCell"];

    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic2.png"]];
    self.friendsTableView.backgroundColor = [UIColor clearColor];

	 newFriend= [[UITextField alloc]initWithFrame:CGRectMake(15, 7, 200, 30)];
//    [newFriend setTextAlignment:NSTextAlignmentCenter];
    [newFriend setBorderStyle:UITextBorderStyleRoundedRect];
    newFriend.placeholder = @"Please look forward to!";
    newFriend.delegate = self;
    newFriend.userInteractionEnabled = NO;
    [self.topView addSubview:newFriend];
    
    [self uploadRoser];
    
    [[XMPPManager instence]setDelegate:self];

    
//    //随意点击去键盘
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:newFriend action:@selector(resignFirstResponder)];
//    [self.view addGestureRecognizer:tapGes];


}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setFriendsTableView:nil];


    [self setTopView:nil];

    [self setFriendLabel:nil];
    [super viewDidUnload];
}


#pragma mark - AKTabBarCtr Methods
- (NSString *)tabImageName
{
	return @"image-1";
    
}

- (NSString *)tabTitle
{
	return self.title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - private method
-(void)uploadRoser
{
    [self.friendsList removeAllObjects];
    [self.friendsList addObjectsFromArray:[XMPPManager instence].roster];
    
}

- (UIImage *)configurePhotoForCell:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	UIImage *headImage = [[UIImage alloc]init];
    
	if (user.photo != nil)
	{
		headImage = user.photo;
	}
	else
	{
		NSData *photoData = [[[XMPPManager instence] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
		if (photoData != nil)
			headImage = [UIImage imageWithData:photoData];
		else
			headImage = [UIImage imageNamed:@"Icon-72.png"];
	}
    return headImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [[[self fetchedResultsController]sections]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [[XMPPManager instence].chartListsForCurrentUser count];
//    return [self.friendsList count];
    NSArray *sections = [[self fetchedResultsController] sections];
    NSLog(@"sectons %d",[sections count]);
	
	if (section < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    
    NSString *name = [user displayName];
        if ( [name isEqualToString:@"null"]) {
            name = [user nickname];
       }
       if ([name isEqualToString:@"null"]) {
            name = [user jidStr];
        }
    cell.nameLabel.text = name;
    cell.ideaLabel.text = [[[user primaryResource] presence] status];
    cell.headImage.image = [self configurePhotoForCell:user];
    [cell setUnReadMessage:[user unreadMessages]];
//    [cell setUnReadMessage:@(13)];
    NSLog(@"%d",[[user unreadMessages]integerValue]);
//    NSLog(@"%@",[user ask]);
//    NSLog(@"%@",[user jidStr]);
//    NSLog(@"%@",[user subscription]);
//    NSLog(@"%d",[[user unreadMessages]integerValue]);
//    NSLog(@"%d",[[[user primaryResource]priorityNum]integerValue]);
//    NSLog(@"%@",[[user primaryResource]show]);
//    NSLog(@"%d",[[[user primaryResource]showNum]integerValue]);
    
//    [self configurePhotoForCell:cell user:user];
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}




#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController]objectAtIndexPath:indexPath];
    
    

    [XMPPManager instence].toSomeOne = [user.jid copy];
    
    [XMPPManager instence].friendHeadImage = [self configurePhotoForCell:user];
    NSLog(@"%@",[XMPPManager instence].toSomeOne);
    [self.delegate goToChartroom];
}



#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [newFriend resignFirstResponder];
    return YES;
}

- (IBAction)didClikAddFriendsButton:(UIButton *)sender {
    //打印聊天列表
    [[XMPPManager instence]printCoreData:nil];

    if ([newFriend.text isEqualToString:@""]) {
        return;
    }else{
    [[XMPPManager instence] addNewFriend:newFriend.text];
    newFriend.text = @"";
    }
}

#pragma mark - XMPPManager Delegate
//-(void)reloadTableView
//{
//    [self.friendsList removeAllObjects];
//    [self.friendsList addObjectsFromArray:[XMPPManager instence].roster];
//    
//    NSLog(@"fwfwf好友列表%@",self.friendsList);
//    [self.friendsTableView reloadData];
//}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark NSFetchedResultsController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
/*
- (NSFetchedResultsController *)fetchedResultsController
{
   
        fetchedResultsController = [[XMPPManager instence]XMPPRosterFetchedResultsController];
    
    
    return fetchedResultsController;
}
*/

#pragma mark - XMPPManger Delegate
//查询XMPPROSTER成功返回fentchControll
-(void)controllerDidChangedWithFetchedResult:(NSFetchedResultsController *)fetchedResultsController
{
    [[self friendsTableView] reloadData];
    
}



@end
