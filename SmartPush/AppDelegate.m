//
//  AppDelegate.m
//  SmartPush
//
//  Created by Saurav, Amit on 7/1/15.
//  Copyright (c) 2015 Saurav, Amit. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ServiceHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{


    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSLog(@"deviceToken: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[ServiceHelper sharedInstance] logText:@"remote_notification_1"];
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"Received notifiation %@",msg);
    [self createAlert:msg];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[ServiceHelper sharedInstance] logText:@"remote_notification_2"];
    NSLog(@"Informed server about wake up!");

    NSMutableDictionary *aps = [userInfo valueForKey:@"aps"];

    if ([aps valueForKey:@"alert"] == nil) {
        ViewController *controller = (ViewController *)self.window.rootViewController;
        [controller createGeo];
    } else {
        [self createAlert:[aps valueForKey:@"alert"]];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)createAlert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end
