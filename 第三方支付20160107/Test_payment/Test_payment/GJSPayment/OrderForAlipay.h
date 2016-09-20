//
//  OrderForAlipay.h
//  Test_payment
//
//  Created by forp on 15/12/2.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderForAlipay : NSObject

@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * seller;
@property(nonatomic, copy) NSString * tradeNO;
@property(nonatomic, copy) NSString * productName;
@property(nonatomic, copy) NSString * productDescription;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * notifyURL;
@property(nonatomic, copy) NSString * signedString;

@property(nonatomic, copy) NSString * rsaDate;//可选
@property(nonatomic, copy) NSString * appID;//可选

- (instancetype)initWithDictionary:(NSDictionary *)dicData;

@end
