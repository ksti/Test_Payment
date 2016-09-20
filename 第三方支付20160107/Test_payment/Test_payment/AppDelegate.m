//
//  AppDelegate.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GJSUtils.h"
#import <AlipaySDK/AlipaySDK.h>

#import "WechatPayManager.h"
#import "GJSPay.h"

@interface AppDelegate () <WechatPayManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //注册app
    [WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"demo 2.0"];
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([PaySDK isEqualToString:AlipayType]) {
        if ([url.host isEqualToString:@"safepay"]) {//需要自己提供一个处理openURL的方法
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                //保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果
            }];
        }
    } else if ([PaySDK isEqualToString:WXpayType]) {
        //处理微信通过URL启动App时传递的数据
        [WechatPayManager sharedManager].delegate = self;
        return [WXApi handleOpenURL:url delegate:[WechatPayManager sharedManager]];
    } else if ([PaySDK isEqualToString:UnionpayType]) {
        //处理银联通过URL启动App时传递的数据
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([PaySDK isEqualToString:WXpayType]) {
        [WechatPayManager sharedManager].delegate = self;
        return [WXApi handleOpenURL:url delegate:[WechatPayManager sharedManager]];
    }
    return YES;
}

- (void)managerDidRecvPayReq:(PayReq *)request {
    
}

- (void)managerDidRecvPayResponse:(PayResp *)response {
    //启动微信支付的response
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", response.errCode];
    /*
    if([response isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (response.errCode) {
            case 0:
                strMsg = @"支付结果：成功！";
                break;
            case -1:
                strMsg = @"支付结果：失败！";
                break;
            case -2:
                strMsg = @"用户已经退出支付！";
                break;
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
                break;
        }
    }
    */
    if ([response isKindOfClass:[PayResp class]]){
        switch(response.errCode){
            case WXSuccess:/**< 成功    */
                //服务器端查询支付通知或查询API返回的结果再提示成功
            {
                strMsg = @"支付结果：成功！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"success" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case WXErrCodeCommon:/**< 普通错误类型    */
            {
                strMsg = @"支付结果：失败！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case WXErrCodeUserCancel:/**< 用户点击取消并返回    */
            {
                strMsg = @"用户已经退出支付！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"cancel" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case WXErrCodeSentFail:/**< 发送失败    */
            {
                strMsg = @"支付结果：发送失败！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case WXErrCodeAuthDeny:/**< 授权失败    */
            {
                strMsg = @"支付结果：授权失败！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            case WXErrCodeUnsupport:/**< 微信不支持    */
            {
                strMsg = @"微信不支持！";
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
                NSNotification *notification = [NSNotification notificationWithName:ORDER_PAY_NOTIFICATION object:@"fail" userInfo:@{@"payType": WXpayType, @"message": strMsg, @"response": response}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
        }
    }
}

@end
