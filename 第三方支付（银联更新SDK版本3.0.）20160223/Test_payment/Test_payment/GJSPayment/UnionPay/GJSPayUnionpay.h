//
//  GJSUnionpay.h
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayProtocol.h"
//#import "UPPayPlugin.h"
#import "UPPaymentControl.h"

@interface GJSPayUnionpay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

/*! @brief 处理银联支付通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 银联支付启动第三方应用(即本应用)时传递过来的URL
 * @param delegate  GJSPayProtocol对象，用来接收银联支付触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
+(BOOL) handleOpenURL:(NSURL *) url delegate:(id<GJSPayProtocol>) delegate;

/**
 验证签名
 */
+ (BOOL) verify:(NSString *) resultStr;

/**
 选中商品调用银联支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController;

@end
