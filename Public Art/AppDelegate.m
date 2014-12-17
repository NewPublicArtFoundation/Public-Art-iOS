//
//  AppDelegate.m
//  GraffitiFound
//
//  Created by Leonard Bogdonoff on 10/24/14.
//  Copyright (c) 2014 New Public Art Foundation. All rights reserved.
//


#import "Mixpanel.h"
#import "AppDelegate.h"
#import "NearbyListViewController.h"
#import "NearbyListWebViewController.h"
#import "LocationSettingsViewController.h"
#import <Parse/Parse.h>

#define MIXPANEL_TOKEN @"84d416fdfbfe20f78a60d04ab08cbc8c"
#define PARSE_APPID @"w7cmSk6gNvSreZAEMVLdI1moBHDxumKJtyHkx1Iz"
#define PARSE_CLIENTKEY @"kxUUwGsz7UIE0PLQV1jYbmfqzf6klPSa64WSlaGs"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:PARSE_APPID
                  clientKey:PARSE_CLIENTKEY];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // 3. Set up the root view
    NearbyListViewController *lvc = [[NearbyListViewController alloc] initWithStyle:UITableViewStylePlain];
    NearbyListWebViewController *wvc = [[NearbyListWebViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:lvc];
    lvc.webViewController = wvc;
    
    [self.window setRootViewController:navigationController];
    [navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.596 green:0.596 blue:0.596 alpha:1] /*#989898*/}];
    self.window.backgroundColor = [UIColor blackColor];
    self.window.tintColor = [UIColor colorWithRed:0.596 green:0.596 blue:0.596 alpha:1] /*#989898*/;
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.0];
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
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

