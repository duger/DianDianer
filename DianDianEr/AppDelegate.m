//
//  AppDelegate.m
//  DianDianEr
//
//  Created by 王超 on 13-10-17.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <Parse/Parse.h>

@implementation AppDelegate
{
    UIBackgroundTaskIdentifier bgTask;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Parse setApplicationId:@"wcrPmcMNUzBtMUhWCWQWzmH5rGk1oMBqhwz4wOPe"
                  clientKey:@"6eohyeYe9zRGwBShYMNszo3KwncRDhYeVDMP3Bp2"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    NSLog(@"%d",IS_IPHONE5);
    NSLog(@"系统版本%f",[[[UIDevice  currentDevice]systemVersion]floatValue]);
    [[SelectManager defaultManager]downloadDateFromServiceToLocal:1];

    [[XMPPManager instence]setupStream];
    
    
    PFObject *player = [PFObject objectWithClassName:@"Player"];//1
    [player setObject:@"John" forKey:@"Name"];
    [player setObject:[NSNumber numberWithInt:1230] forKey:@"Score"];//2

    [player saveInBackground];//3

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
        {
            [application setKeepAliveTimeout:600 handler:^{
                
                //			DDLogVerbose(@"KeepAliveHandler");
                NSLog(@"keepAliveHandler");
                // Do other keep alive stuff here.
            }];
        }
        
        
        
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[XMPPManager instence]teardownStream];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
     [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    application.applicationIconBadgeNumber = 0;
    
    
    [application cancelLocalNotification:notification];
}



@end
