//
//  AppDelegate.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//


#import <TSMessage.h>
#import "Mixpanel.h"
#import "AppDelegate.h"
#import "NearbyListViewController.h"
#import "NearbyListWebViewController.h"
#import "LocationSettingsViewController.h"
#import "RKSwipeBetweenViewControllers.h"

#define MIXPANEL_TOKEN @"84d416fdfbfe20f78a60d04ab08cbc8c"

@interface AppDelegate ()

@end    

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Later, you can get your instance with
    
    [mixpanel identify:mixpanel.distinctId];
    NSLog(@"%@", mixpanel.distinctId);
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound |
      UIRemoteNotificationTypeAlert)];
    
 
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    RKSwipeBetweenViewControllers *navigationController = [[RKSwipeBetweenViewControllers alloc]initWithRootViewController:pageController];
   
    
    // 3. Set up the root view
    NearbyListViewController *lvc = [[NearbyListViewController alloc] initWithStyle:UITableViewStylePlain];
    NearbyListWebViewController *wvc = [[NearbyListWebViewController alloc] init];
    lvc.webViewController = wvc;
    
    //%%% DEMO CONTROLLERS
//    UIViewController *demo1 = [[UIViewController alloc]init];
    UIViewController *demo2 = [[UIViewController alloc]init];
    demo2.view.backgroundColor = [UIColor whiteColor];
    [navigationController.viewControllerArray addObjectsFromArray:@[lvc/*,demo2,demo1,demo4*/]];
   
    
    self.window.backgroundColor = [UIColor blackColor];
    self.window.tintColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
    }


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
