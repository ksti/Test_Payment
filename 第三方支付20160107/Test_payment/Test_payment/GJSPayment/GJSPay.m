//
//  GJSPay.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSPay.h"
#import "DataVerifier.h"
#import "NSString+QLString.h"
#import "TestWechatPay.h"

#define TESTRESULT @"partner=\"2088101568358171\"&seller_id=\"xxx@alipay.com\"&out_trade_no=\"0819145412-6177\"&subject=\"测试\"&body=\"测试测试\"&total_fee=\"0.01\"&notify_url=\"http://notify.msp.hk/notify.htm\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&success=\"true\"&sign_type=\"RSA\"&sign=\"hkFZr+zE9499nuqDNLZEF7W75RFFPsly876QuRSeN8WMaUgcdR00IKy5ZyBJ4eldhoJ/2zghqrD4E2G2mNjs3aE+HCLiBXrPDNdLKCZgSOIqmv46TfPTEqopYfhs+o5fZzXxt34fwdrzN4mX6S13cr3UwmEV4L3Ffir/02RBVtU=\""
@interface GJSPay () <GJSPayProtocol> {
    GJSPayWXpay *wxPay;
}

@end

@implementation GJSPay

/**
 *  返回数据格式,测试假数据
 partner="2088101568358171"&seller_id="xxx@alipay.com"&out_trade_no="0819145412-6177"&subject="测试"&body="测试测试"&total_fee="0.01"&notify_url="http://notify.msp.hk/notify.htm"&service="mobile.securitypay.pay"&payment_type="1"&_input_charset="utf-8"&it_b_pay="30m"&success="true"&sign_type="RSA"&sign="hkFZr+zE9499nuqDNLZEF7W75RFFPsly876QuRSeN8WMaUgcdR00IKy5ZyBJ4eldhoJ/2zghqrD4E2G2mNjs3aE+HCLiBXrPDNdLKCZgSOIqmv46TfPTEqopYfhs+o5fZzXxt34fwdrzN4mX6S13cr3UwmEV4L3Ffir/02RBVtU="
 */

/**
 *  支付成功代理
 */
- (void)paymentDidSuccess:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([type isEqualToString:AlipayType]) {//支付宝支付
        if ([response isKindOfClass:[NSDictionary class]]) {
            response = (NSDictionary *)response;
        } else {
            return;
        }
        /**
         *  推荐使用服务器验证而非本地验证,从服务器请求支付结果比较妥!
             NSString *memo = response[@"memo"];
             NSString *result = response[@"result"];
             if ([self verify:result]) {
             //验证通过
             NSLog(@"验证通过");
             } else {
             //验证不通过
             NSLog(@"验证不通过");
             }
         */
    } else if ([type isEqualToString:WXpayType]) {//微信支付
        //
    } else if ([type isEqualToString:UnionpayType]) {//银联支付
        //
    }
    
    if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
        [self.delegate paymentDidSuccess:payment responseInfo:response payType:type];
    }
}
/**
 *  支付失败代理
 */
- (void)paymentDidFailed:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
        [self.delegate paymentDidFailed:payment responseInfo:response payType:type];
    }
}
/**
 *  支付取消代理
 */
- (void)paymentDidCanceled:(id)payment responseInfo:(id)response payType:(NSString *)type {
    if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
        [self.delegate paymentDidCanceled:payment responseInfo:response payType:type];
    }
}
/**
 *  支付状态代理
 */
- (void)paymentStatus:(id)payment statusInfo:(id)info payType:(NSString *)type {
    if ([self.delegate respondsToSelector:@selector(paymentStatus:statusInfo:payType:)]) {
        [self.delegate paymentStatus:payment statusInfo:info payType:type];
    }
}

/**
 调用支付宝支付
 */
//自定义product
- (void)payByAlipayProduct:(id<ProductItem>)product partner:(NSString *)partner seller:(NSString *)seller partnerPrivKey:(NSString *)partnerPrivKey appURLScheme:(NSString *)appURLScheme md5_key:(NSString *)md5_key {
    GJSPayAlipay *alipay = [[GJSPayAlipay alloc] init];
    alipay.delegate = self;
    alipay.partner = partner;
    alipay.seller = seller;
    alipay.partnerPrivKey = partnerPrivKey;
    alipay.appURLScheme = appURLScheme;
    alipay.md5_key = md5_key;
    [alipay actionPayProduct:product];
}
//自定义order
- (void)payByAlipayOrder:(id<OrderItem>)order partner:(NSString *)partner seller:(NSString *)seller appURLScheme:(NSString *)appURLScheme md5_key:(NSString *)md5_key {
    GJSPayAlipay *alipay = [[GJSPayAlipay alloc] init];
    alipay.delegate = self;
    alipay.partner = partner;
    alipay.seller = seller;
    alipay.appURLScheme = appURLScheme;
    alipay.md5_key = md5_key;
    [alipay actionPayOrder:order];
}

#pragma mark -
#pragma mark utils

- (NSDictionary *)handleResult:(NSString *)resultStr {
    NSRange range = [resultStr rangeOfString:@"&sign_type"];
    NSMutableDictionary *mDictResult = [[NSMutableDictionary alloc] init];
    if (range.location != NSNotFound) {
        NSString *strOrderInfo = [resultStr substringToIndex:range.location];
        [mDictResult setObject:strOrderInfo forKey:@"orderInfo"];
    }
    
    NSArray *arrResult = [resultStr componentsSeparatedByString:@"&"];
    for (NSString *string in arrResult) {
        NSString *key = @"key";
        NSArray *arrTemp = [string componentsSeparatedByString:@"="];
        if (arrTemp.count>1) {
            key = [arrTemp firstObject];
        }
        NSRange range1 = [string rangeOfString:@"\""];
        if (range1.location != NSNotFound) {
            NSString *string2 = [string substringFromIndex:range1.location+range1.length];
            NSRange range2 = [string2 rangeOfString:@"\""];
            if (range2.location != NSNotFound) {
                NSString *value = [string substringWithRange:NSMakeRange(range1.location+range1.length, range2.location)];
                [mDictResult setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:mDictResult];
}

- (BOOL)verify:(NSString *)result {
    if (!result) {
        return NO;
    }
    NSDictionary *dictResult = [self handleResult:result];
    NSString *sign = [dictResult objectForKey:@"sign"];
    NSString *orderInfo = [dictResult objectForKey:@"orderInfo"];
    //获取支付宝公钥验证签名
    NSString *publicKey = [NSString getValidStringWithObject:self.alipayPubKey];
    publicKey = AlipayPubKey;
    if (publicKey.length<=0) {
        return NO;
    }
    id<DataVerifier> verifier = CreateRSADataVerifier(publicKey);
    if (orderInfo) {
        return [verifier verifyString:orderInfo withSign:sign];
    }
    
    return NO;
}

#pragma mark --
#pragma mark 微信支付
/**
 调用微信支付
 */
//自定义product
- (void)payByWXpayProduct:(id<ProductItem>)product appId:(NSString *)appId partner:(NSString *)partner mchId:(NSString *)mchId {
    //GJSPayWXpay *wxPay = [[GJSPayWXpay alloc] init];
    wxPay = [[GJSPayWXpay alloc] init];
    wxPay.delegate = self;
    wxPay.appId = appId;
    wxPay.partnerId = partner;
    wxPay.mchId = mchId;
    [wxPay actionPayProduct:product];
}
//自定义order
- (void)payByWXpayOrder:(id<OrderItem>)order appId:(NSString *)appId partner:(NSString *)partner mchId:(NSString *)mchId {
    //GJSPayWXpay *wxPay = [[GJSPayWXpay alloc] init];
    wxPay = [[GJSPayWXpay alloc] init];
    wxPay.delegate = self;
    wxPay.appId = appId;
    wxPay.partnerId = partner;
    wxPay.mchId = mchId;
    [wxPay actionPayOrder:order];
}

#pragma mark --
#pragma mark 银联支付
/**
 调用银联支付
 */
//自定义order
- (void)payByUnionPayOrder:(id<OrderItem>)order viewController:(UIViewController *)viewController {
    GJSPayUnionpay *unionPay = [[GJSPayUnionpay alloc] init];
    unionPay.delegate = self;
    [unionPay actionPayOrder:order viewController:viewController];
}

#pragma mark -
#pragma mark test

- (void)testAlipay {
    [self testVerify];//测试验证签名
}

- (void)testVerify {
    if ([self verify:TESTRESULT]) {
        //验证通过
        NSLog(@"验证通过");
    } else {
        //验证不通过
        NSLog(@"验证不通过");
    }
}

@end
