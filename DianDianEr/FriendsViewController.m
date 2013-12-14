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

@interface FriendsViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation FriendsViewController
{
    UITextField *newFriend;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //        self.view.backgroundColor = [UIColor lightGrayColor];
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.title = @"好友";
    self.friendsList = [[NSMutableArray alloc]init];
//    self.friendsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background2.png"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[XMPPManager instence]setFriendsHeadImage];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iPhone5-backpic2.png"]];
    self.friendsTableView.backgroundColor = [UIColor clearColor];

	 newFriend= [[UITextField alloc]initWithFrame:CGRectMake(15, 7, 200, 30)];
//    [newFriend setTextAlignment:NSTextAlignmentCenter];
    [newFriend setBorderStyle:UITextBorderStyleRoundedRect];
    newFriend.placeholder = @"Please look forward to!";
    newFriend.delegate = self;
    newFriend.userInteractionEnabled = NO;
    [self.topView addSubview:newFriend];
    self.dataArray = [[NSMutableArray alloc]init];
//    [self getData];
//    [self uploadRoser];
//    [self.friendsList addObject:@"测试"];

//    [self reloadFriendList];
    NSLog(@"好友列表%@",self.friendsList);
//    [self.friendsTableView reloadData];
    [XMPPManager instence].delegate = self;
    
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

- (void)getData{
    NSManagedObjectContext *context = [[XMPPManager instence] managedObjectContext_roster];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSError *error ;
    NSArray *friends = [context executeFetchRequest:request error:&error];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:friends];
    NSLog(@"%@",friends);
}


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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [[XMPPManager instence].chartListsForCurrentUser count];
    return [self.friendsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"list.png"];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    // Configure the cell...
//    XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:indexPath.row];
//    NSString *name = [object displayName];
//    if (!name) {
//        name = [object nickname];
//    }
//    if (!name) {
//        name = [object jidStr];
//    }
//    cell.textLabel.text = name;
//    cell.detailTextLabel.text = [[[object primaryResource] presence] status];
//    cell.tag = indexPath.row;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(25, 10, 240, 30)];
    [cell addSubview:label];
    label.text = self.friendsList[indexPath.row];
    
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    label.textColor = [UIColor whiteColor];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [XMPPManager instence].toSomeOne = self.friendsList[indexPath.row];
    NSLog(@"%@",[XMPPManager instence].toSomeOne);
    [self.delegate goToChartroom];
}
//- (void)prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender
//{
//    UITableViewCell *cell = (UITableViewCell *)sender;
//    if ([[segue destinationViewController] isKindOfClass:[ChartViewController class] ]) {
//        XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:cell.tag];
//        ChartViewController *chat = segue.destinationViewController;
//        chat.xmppUserObject = object;
//    }
//}



#pragma mark - XMPPManager Delegate
-(void)reloadTableView
{
    [self.friendsList removeAllObjects];
    [self.friendsList addObjectsFromArray:[XMPPManager instence].roster];

    NSLog(@"fwfwf好友列表%@",self.friendsList);
    [self.friendsTableView reloadData];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [newFriend resignFirstResponder];
    return YES;
}

- (IBAction)didClikAddFriendsButton:(UIButton *)sender {

    if ([newFriend.text isEqualToString:@""]) {
        return;
    }else{
    [[XMPPManager instence] addNewFriend:newFriend.text];
    newFriend.text = @"";
    }
}
@end
