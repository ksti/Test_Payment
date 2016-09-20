//
//  OrderForAlipay.m
//  Test_payment
//
//  Created by forp on 15/12/2.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "OrderForAlipay.h"
#import "GJSPayProtocol.h"
#import "NSString+QLString.h"

@interface OrderForAlipay () <OrderItem>

@end

@implementation OrderForAlipay

- (instancetype)initWithDictionary:(NSDictionary *)dicData {
    if (self = [super init]) {
        _partner = [NSString getValidStringWithObject:dicData[@"Partner"]];
        _seller = [NSString getValidStringWithObject:dicData[@"Seller"]];
        _tradeNO = [NSString getValidStringWithObject:dicData[@"TradeNO"]];
        _productName = [NSString getValidStringWithObject:dicData[@"ProductName"]];
        _productDescription = [NSString getValidStringWithObject:dicData[@"ProductDescription"]];
        _amount = [NSString getValidStringWithObject:dicData[@"Amount"]];
        _notifyURL = [NSString getValidStringWithObject:dicData[@"NotifyURL"]];
        _signedString = [NSString getValidStringWithObject:dicData[@"SignedString"]];
        _rsaDate = [NSString getValidStringWithObject:dicData[@"RSADate"]];
        _appID = [NSString getValidStringWithObject:dicData[@"AppID"]];
    }
    return self;
}

- (NSString *)partner {
    return _partner;
}
- (NSString *)seller {
    return _seller;
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
- (NSString *)rsaDate {
    return _rsaDate;
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
