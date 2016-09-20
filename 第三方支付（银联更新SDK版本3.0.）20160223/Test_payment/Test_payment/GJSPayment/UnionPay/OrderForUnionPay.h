//
//  OrderForUnionPay.h
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderForUnionPay : NSObject

@property(nonatomic, copy) NSString * tradeNO;
@property(nonatomic, copy) NSString * productName;
@property(nonatomic, copy) NSString * productDescription;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * notifyURL;

- (instancetype)initWithDictionary:(NSDictionary *)dicData;

@end
