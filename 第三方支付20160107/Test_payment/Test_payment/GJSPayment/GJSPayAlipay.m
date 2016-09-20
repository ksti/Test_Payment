//
//  GJSPayAlipay.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSPayAlipay.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "ProductForAlipay.h"
#import "AlipayPartnerConfig.h"

@interface GJSPayAlipay ()

@end

@implementation GJSPayAlipay

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    //srand((unsigned)time(0));//重置随机数种子
    for (int i = 0; i < kNumber; i++)
    {
        //unsigned index = rand() % [sourceStr length];
        unsigned index = arc4random() % [sourceStr length];//自动生成随机种子（arc4 cipher算法），产生随机数范围也更大
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}



#pragma mark -
#pragma mark   ==============产生订单信息==============

- (void)generateData{
    NSString *subjects = @"10";
    NSString *body = @"我是测试数据";
    
    ProductForAlipay *product = [[ProductForAlipay alloc] init];
    product.subject = subjects;
    product.body = body;
    
    product.price = arc4random() % 100;
}

#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============
/**
 选中商品调用支付宝极简支付,自定义Product
 */
- (void)actionPayProduct:(id<ProductItem>)product {
    
    //获取prodcut实例并初始化订单信息
    //如果是空返回
    if (product == nil) {
        return;
    }
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = self.partner;
    NSString *seller = self.seller;
    NSString *privateKey = self.partnerPrivKey;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner; //支付宝分配给商户的ID
    order.seller = seller; //收款支付宝账号（用于收💰）
    //order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.tradeNO = [product orderId]; //订单ID（由商家自行制定）
    order.productName = [product subject]; //商品标题
    order.productDescription = [product body]; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",[product price]]; //商品价格
    //order.notifyURL =  @"http://www.xxx.com"; //回调URL
    order.notifyURL = [product notifyURL]; //回调URL
    
    order.service = @"mobile.securitypay.pay"; //接口名称, 固定值, 不可空
    order.paymentType = @"1"; //支付类型 默认值为1(商品购买), 不可空
    order.inputCharset = @"utf-8"; //参数编码字符集: 商户网站使用的编码格式, 固定为utf-8, 不可空
    order.itBPay = @"30m"; //未付款交易的超时时间 取值范围:1m-15d, 可空
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    //NSString *appScheme = @"alisdkdemo";
    NSString *appScheme = self.appURLScheme;
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //解析返回数据，移交代理处理
            NSString *resultStatus = resultDic[@"resultStatus"];
            if ([resultStatus isEqualToString:@"9000"]) {//订单支付成功
                if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
                    [self.delegate paymentDidSuccess:product responseInfo:resultDic payType:AlipayType];
                }
            } else if ([resultStatus isEqualToString:@"4000"] || [resultStatus isEqualToString:@"6002"]) {//订单支付失败 | 网络连接出错
                if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                    [self.delegate paymentDidFailed:product responseInfo:resultDic payType:AlipayType];
                }
            } else if ([resultStatus isEqualToString:@"6001"]) {//用户中途取消
                if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
                    [self.delegate paymentDidCanceled:product responseInfo:resultDic payType:AlipayType];
                }
            } else {//其他情况交给代理处理，其实文档中只剩下8000这个状态码：正在处理中
                if ([self.delegate respondsToSelector:@selector(paymentStatus:statusInfo:payType:)]) {
                    [self.delegate paymentStatus:product statusInfo:resultDic payType:AlipayType];
                }
            }
        }];
    }
}

/**
 选中商品调用支付宝极简支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder {
    
    //获取customOrder实例并初始化订单信息
    //如果是空返回
    if (customOrder == nil) {
        return;
    }
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = self.partner;
    NSString *seller = self.seller;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner; //支付宝分配给商户的ID
    order.seller = seller; //收款支付宝账号（用于收💰）
    //order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.tradeNO = [customOrder tradeNO]; //订单ID（由商家自行制定）
    order.productName = [customOrder productName]; //商品标题
    order.productDescription = [customOrder productDescription]; //商品描述
    order.amount = [customOrder amount]; //商品价格
    //order.notifyURL =  @"http://www.xxx.com"; //回调URL
    order.notifyURL = [customOrder notifyURL]; //回调URL
    
    order.service = @"mobile.securitypay.pay"; //接口名称, 固定值, 不可空
    order.paymentType = @"1"; //支付类型 默认值为1(商品购买), 不可空
    order.inputCharset = @"utf-8"; //参数编码字符集: 商户网站使用的编码格式, 固定为utf-8, 不可空
    order.itBPay = @"30m"; //未付款交易的超时时间 取值范围:1m-15d, 可空
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    //NSString *appScheme = @"alisdkdemo";
    NSString *appScheme = self.appURLScheme;
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    //由服务器端生成的加密签名
    NSString *signedString = [customOrder signedString];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //解析返回数据，移交代理处理
            NSString *resultStatus = resultDic[@"resultStatus"];
            if ([resultStatus isEqualToString:@"9000"]) {//订单支付成功
                if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
                    [self.delegate paymentDidSuccess:order responseInfo:resultDic payType:AlipayType];
                }
            } else if ([resultStatus isEqualToString:@"4000"] || [resultStatus isEqualToString:@"6002"]) {//订单支付失败 | 网络连接出错
                if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
                    [self.delegate paymentDidFailed:order responseInfo:resultDic payType:AlipayType];
                }
            } else if ([resultStatus isEqualToString:@"6001"]) {//用户中途取消
                if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
                    [self.delegate paymentDidCanceled:order responseInfo:resultDic payType:AlipayType];
                }
            } else {//其他情况交给代理处理，其实文档中只剩下8000这个状态码：正在处理中
                if ([self.delegate respondsToSelector:@selector(paymentStatus:statusInfo:payType:)]) {
                    [self.delegate paymentStatus:order statusInfo:resultDic payType:AlipayType];
                }
            }
        }];
    }
}

@end
