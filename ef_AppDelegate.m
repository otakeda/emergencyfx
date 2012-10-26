//
//  ef_AppDelegate.m
//  emergencyfx
//
//  Created by otakeda on 2012/10/22.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import "ef_AppDelegate.h"
#import "ef_ViewController.h"

@implementation ef_AppDelegate

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    [self getUUID];
    
    [self createFrontJob];
    lastCount = 0;
    
    //APNS PUsh通知が使えるように登録
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                                           | UIRemoteNotificationTypeSound
                                                                           | UIRemoteNotificationTypeAlert)];
    // Override point for customization after application launch.
    return YES;
}
// デバイストークンを受信した際の処理
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    NSString *deviceToken = [[[[devToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken: %@", deviceToken);
}
// プッシュ通知を受信した際の処理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
#endif
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
    
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    if (backgroundSupported)
    {
        bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you.
            // stopped or ending the task outright.
            //10分でexpireする。
            NSLog(@"expired!");
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
  
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(;;) {
                NSLog(@"background: ");
                
                [viewController getWarnCount];
                [self determineNotif];
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.viewController updateData];  // dispatch_asyncをはずすと動かない。よくわからんロックされる
                    NSLog(@"reload: ");
                });
                
                [NSThread sleepForTimeInterval:60.0];
                
                if (bgTask==UIBackgroundTaskInvalid) break;
            }
            
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self createFrontJob];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 警告数が前回より大きい場合はsetNotifをcall
- (void)determineNotif{
    int warnCount=[self.viewController getWarnCount];
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = warnCount;
    if (lastCount < warnCount) [self setNotif:warnCount];   //前回よりもwarnCountが大きいときだけNotifiication 呼び出し
    NSLog(@"warn=%d last=%d",warnCount, lastCount);
    lastCount=warnCount;

}

- (void)createFrontJob{
    //フォアグラウンド用のタスクを動かす。dispatch_asyncなので結果を待たずにすぐ次へ
    dispatch_queue_t gcd_queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(gcd_queue, ^{
        for(;;) {
            NSLog(@"Front Job: ");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController updateData];  // dispatch_asyncをはずすと動かない。たぶんviewControllerがちゃんとしてないうちにこれが呼ばれるから？
            });
            [self determineNotif];  // updateDataが非同期で動いているのでこっちが先に終わってしまう
            
            [NSThread sleepForTimeInterval:30.0];
            if (bgTask != UIBackgroundTaskInvalid) break;
            
        }
    });
    
    //バックグラウンドタスクを止める
    UIApplication* app = [UIApplication sharedApplication];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"finished!");
            if (bgTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }
    
    
}
/* ============================================================================== */
#pragma mark - UILocalNotification
/* ============================================================================== */
// 通常、アプリケーションが起動中の場合はローカル通知は通知されないが、通知されるようにする
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *msg = [[NSString alloc]initWithFormat:@"2σ Line Over : %d", lastCount];
    if(notification) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Infomation"
                              message:msg
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
//    [msg release];
}
- (void)setNotif:(int)warnCount{
    NSLog(@"Set Notification");
    // ローカル通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
	
    // 通知日時を設定する。今から10秒後
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
    [notification setFireDate:date];
	
    // タイムゾーンを指定する
    [notification setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *alertmsg = [[NSString alloc]initWithFormat:@"2σ Line Over : %d", warnCount];
    // メッセージを設定する
    [notification setAlertBody:alertmsg];
	
    // 効果音は標準の効果音を利用する
    [notification setSoundName:UILocalNotificationDefaultSoundName];
	
    // ボタンの設定
    [notification setAlertAction:@"Open"];
	
    // ローカル通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
//    [notification release];
    
}
- (void) getUUID
{
    NSInteger alc = [[NSUserDefaults standardUserDefaults] integerForKey:@"alc"];
    NSString *uuidString ;
    if (alc == 0) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
//        uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
//        [[NSUserDefaults standardUserDefaults] setObject: [uuidString autorelease] forKey:@"UUID"];
    }
    else
        uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"alc"];
    NSLog(@"alc=%d",alc);
    NSLog(@"uuid=%@",uuidString);
    
}

@end
