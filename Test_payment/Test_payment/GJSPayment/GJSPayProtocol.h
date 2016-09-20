//
//  GJSPayProtocol.h
//  Test_payment
//
//  Created by forp on 15/12/1.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AlipayType @"Alipay"
#define WXpayType @"WXpay"
#define UnionpayType @"Unionpay"
#define ApplePayCUPType @"ApplePayCUP"

#define ORDER_PAY_NOTIFICATION @"order_pay_notification"

#define FromUrlScheme @"paymentDemo" //本应用自定义的urlScheme,便于其他应用调用

 // 支付商品模型需遵循的协议
@protocol ProductItem <NSObject>

@required
- (CGFloat)price; //商品价格
- (NSString *)subject; //商品标题
- (NSString *)body; //商品描述
- (NSString *)orderId; //商品关联的订单Id
- (NSString *)notifyURL; //回调URL

@end

// 支付商品模型需遵循的协议
@protocol OrderItem <NSObject>

@required
- (NSString *)partner;//支付宝分配给商户的ID //微信
- (NSString *)seller;//收款支付宝账号（用于收💰） //
- (NSString *)tradeNO;//交易流水号
- (NSString *)productName;//订单商品名称
- (NSString *)productDescription;//订单商品描述
- (NSString *)amount;//订单总价
- (NSString *)notifyURL;//回调地址,支付结果会回调给服务器端
- (NSString *)signedString;//服务器端用商户私钥签名,商户私钥由服务器保存,不必传入私钥,直接提供签名

- (NSString *)noncestr;//微信支付用
- (NSString *)prepayid;//微信支付用
@optional
- (NSString *)rsaDate;//可选
- (NSString *)appID;//可选

@end

 // 支付需遵循的协议
@protocol GJSPayProtocol <NSObject>

@optional
/**
 *  支付成功代理
 */
- (void)paymentDidSuccess:(id)payment responseInfo:(id)response payType:(NSString *)type;
/**
 *  支付失败代理
 */
- (void)paymentDidFailed:(id)payment responseInfo:(id)response payType:(NSString *)type;
/**
 *  支付取消代理
 */
- (void)paymentDidCanceled:(id)payment responseInfo:(id)response payType:(NSString *)type;
/**
 *  支付状态代理
 */
- (void)paymentStatus:(id)payment statusInfo:(id)info payType:(NSString *)type;

@end
