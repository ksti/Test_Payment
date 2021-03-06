//
//  ProductForWXpay.m
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import "ProductForWXpay.h"
#import "GJSPayProtocol.h"
#import "NSString+QLString.h"

@interface ProductForWXpay () <ProductItem>

@end

@implementation ProductForWXpay

- (instancetype)initWithDictionary:(NSDictionary *)dicData {
    if (self = [super init]) {
        _price = [[NSString getValidStringWithObject:dicData[@"Price"]] floatValue];
        _subject = [NSString getValidStringWithObject:dicData[@"Subject"]];
        _body = [NSString getValidStringWithObject:dicData[@"Body"]];
        _orderId = [NSString getValidStringWithObject:dicData[@"OrderId"]];
        _notifyURL = [NSString getValidStringWithObject:dicData[@"NotifyURL"]];
    }
    return self;
}

- (CGFloat)price {
    return _price;
}

- (NSString *)subject {
    return _subject;
}

- (NSString *)body {
    return _body;
}

- (NSString *)orderId {
    return _orderId;
}

- (NSString *)notifyURL {
    return _notifyURL;
}

@end
