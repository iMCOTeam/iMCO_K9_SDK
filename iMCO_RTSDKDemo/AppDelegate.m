//
//  AppDelegate.m
//  iMCO_RTSDKDemo
//
//  Created by aimoke on 2017/7/3.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <iMCOK9SDK/iMCOK9SDK.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([SVProgressHUD respondsToSelector:@selector(setMinimumDismissTimeInterval:)]) {
        [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    }
    [ZHRealTekDataManager shareRealTekDataManager].AppKey = @"keyOPCjEL08cCCIgm33y8cmForWXLSR9uLT";
    [ZHRealTekDataManager shareRealTekDataManager].AppSecret = @"secaab78b9d7dbe11e7a420ee796be10e85-i6ff579j49afj5";
    
   
    // Override point for customization after application launch.
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
