//
//  GJSPay.h
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayAlipay.h"
#import "GJSPayWXpay.h"
#import "GJSPayUnionpay.h"
#import "GJSPayApplePayCUP.h"
#import "AlipayPartnerConfig.h"
#import "WXpayPartnerConfig.h"


@interface GJSPay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

/*! @brief 处理某某支付通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 某某支付启动第三方应用(即本应用)时传递过来的URL
 * @param delegate  GJSPayProtocol对象，用来接收某某支付触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
+(BOOL) handleOpenURL:(NSURL *) url delegate:(id<GJSPayProtocol>) delegate;

/*=================================*/
/*==============支付宝==============*/
/*=================================*/
/** 支付宝公钥 */
@property (nonatomic, copy) NSString *alipayPubKey;//RSA公钥是做验证签名用的
- (BOOL)verify:(NSString *)result; //本地验证签名,可选
/**
 *  自定义product
 */
- (void)payByAlipayProduct:(id<ProductItem>)product partner:(NSString *)partner seller:(NSString *)seller partnerPrivKey:(NSString *)partnerPrivKey appURLScheme:(NSString *)appURLScheme md5_key:(NSString *)md5_key;
/**
 *  自定义order
 */
- (void)payByAlipayOrder:(id<OrderItem>)order partner:(NSString *)partner seller:(NSString *)seller appURLScheme:(NSString *)appURLScheme md5_key:(NSString *)md5_key;

/*===================================*/
/*==============微信支付==============*/
/*==================================*/
/**
 *  自定义product
 */
- (void)payByWXpayProduct:(id<ProductItem>)product appId:(NSString *)appId partner:(NSString *)partner mchId:(NSString *)mchId;
/**
 *  自定义order
 */
- (void)payByWXpayOrder:(id<OrderItem>)order appId:(NSString *)appId partner:(NSString *)partner mchId:(NSString *)mchId;

/*===================================*/
/*==============银联支付==============*/
/*==================================*/
/**
 *  自定义order
 */
- (void)payByUnionPayOrder:(id<OrderItem>)order viewController:(UIViewController *)viewController;

/*===================================*/
/*==============苹果支付==============*/
/*==================================*/
/**
 *  自定义order
 */
- (void)payByApplePayCUPOrder:(id<OrderItem>)order viewController:(UIViewController *)viewController;

@end
