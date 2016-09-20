//
//  OrderForWXpay.m
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "OrderForWXpay.h"
#import "GJSPayProtocol.h"
#include "NSString+QLString.h"

@interface OrderForWXpay () <OrderItem>

@end

@implementation OrderForWXpay

- (instancetype)initWithDictionary:(NSDictionary *)dicData {
    if (self = [super init]) {
        _partner = [NSString getValidStringWithObject:dicData[@"Partner"]];
        _mch = [NSString getValidStringWithObject:dicData[@"Mch"]];
        _tradeNO = [NSString getValidStringWithObject:dicData[@"TradeNO"]];
        _productName = [NSString getValidStringWithObject:dicData[@"ProductName"]];
        _productDescription = [NSString getValidStringWithObject:dicData[@"ProductDescription"]];
        _amount = [NSString getValidStringWithObject:dicData[@"Amount"]];
        _notifyURL = [NSString getValidStringWithObject:dicData[@"NotifyURL"]];
        _signedString = [NSString getValidStringWithObject:dicData[@"SignedString"]];
        _appID = [NSString getValidStringWithObject:dicData[@"AppID"]];
        _noncestr = [NSString getValidStringWithObject:dicData[@"Noncestr"]];
        _prepayid = [NSString getValidStringWithObject:dicData[@"Prepayid"]];
    }
    return self;
}

- (NSString *)partner {
    return _partner;
}
- (NSString *)seller {
    return _mch;
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
    return _signedString;
}
- (NSString *)appID {
    return _appID;
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
