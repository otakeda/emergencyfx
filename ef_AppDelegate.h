//
//  ef_AppDelegate.h
//  emergencyfx
//
//  Created by otakeda on 2012/10/22.
//  Copyright (c) 2012年 otakeda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ef_ViewController;

@interface ef_AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ef_ViewController *viewController;
- (void)determineNotif;
- (NSString *)getDeviceToken;
@end

NSInteger lastCount;
NSString *deviceToken;
UIBackgroundTaskIdentifier bgTask;

