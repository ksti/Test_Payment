//
//  OrderForUnionPay.m
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "OrderForUnionPay.h"
#import "GJSPayProtocol.h"
#import "NSString+QLString.h"

@interface OrderForUnionPay () <OrderItem>

@end

@implementation OrderForUnionPay

- (instancetype)initWithDictionary:(NSDictionary *)dicData {
    if (self = [super init]) {
        _tradeNO = [NSString getValidStringWithObject:dicData[@"TradeNO"]];
        _productName = [NSString getValidStringWithObject:dicData[@"ProductName"]];
        _productDescription = [NSString getValidStringWithObject:dicData[@"ProductDescription"]];
        _amount = [NSString getValidStringWithObject:dicData[@"Amount"]];
        _notifyURL = [NSString getValidStringWithObject:dicData[@"NotifyURL"]];
    }
    return self;
}

- (NSString *)partner {
    return nil;
}
- (NSString *)seller {
    return nil;
}
- (NSString *)tradeNO {
    return _tradeNO;
}
- (NSString *)productName {
    return _productName;
}
- (NSString *)productDescription {
    return _productDescription;
}
- (NSString *)amount {
    return _amount;
}
- (NSString *)notifyURL {
    return _notifyURL;
}
- (NSString *)signedString {
    return nil;
}
- (NSString *)appID {
    return nil;
}
//微信支付用
- (NSString *)noncestr {
    return nil;
}
//微信支付用
- (NSString *)prepayid {
    return nil;
}

@end
