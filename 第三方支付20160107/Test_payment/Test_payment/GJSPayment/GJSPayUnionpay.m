//
//  GJSPayUnionpay.m
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "GJSPayUnionpay.h"
#import "UnionPayPartnerConfig.h"

@interface GJSPayUnionpay () <UPPayPluginDelegate>
{
    id<OrderItem>_order;
}

@end

@implementation GJSPayUnionpay

- (void)UnionPay:(NSString *)tn mode:(NSString *)mode viewController:(UIViewController *)viewController {
    //[UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:self];
    //当获得的tn不为空时，调用支付接口
    if (tn != nil && tn.length > 0)
    {
        [UPPayPlugin startPay:tn mode:mode viewController:viewController delegate:(id<UPPayPluginDelegate>)viewController];
    }
}

- (void)UPPayPluginResult:(NSString*)result {
    //
    if ([result isEqualToString:@"success"]) {//订单支付成功
        if ([self.delegate respondsToSelector:@selector(paymentDidSuccess:responseInfo:payType:)]) {
            [self.delegate paymentDidSuccess:_order responseInfo:result payType:UnionpayType];
        }
    } else if ([result isEqualToString:@"fail"]) {//订单支付失败
        if ([self.delegate respondsToSelector:@selector(paymentDidFailed:responseInfo:payType:)]) {
            [self.delegate paymentDidFailed:_order responseInfo:result payType:UnionpayType];
        }
    } else if ([result isEqualToString:@"cancel"]) {//用户取消支付
        if ([self.delegate respondsToSelector:@selector(paymentDidCanceled:responseInfo:payType:)]) {
            [self.delegate paymentDidCanceled:_order responseInfo:result payType:UnionpayType];
        }
    }
}

/**
 选中商品调用支付宝极简支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController {
    
    //获取customOrder实例并初始化订单信息
    //如果是空返回
    if (customOrder == nil) {
        return;
    }
    _order = customOrder;
    
    [self UnionPay:[customOrder tradeNO] mode:UnionPay_Mode viewController:viewController];
}

@end
