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
#import "AlipayPartnerConfig.h"
#import "WXpayPartnerConfig.h"


@interface GJSPay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

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

@end
