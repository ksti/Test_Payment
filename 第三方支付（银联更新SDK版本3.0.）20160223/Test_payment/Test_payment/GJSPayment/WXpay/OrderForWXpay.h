//
//  OrderForWXpay.h
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderForWXpay : NSObject

@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * mch;
@property(nonatomic, copy) NSString * tradeNO;
@property(nonatomic, copy) NSString * productName;
@property(nonatomic, copy) NSString * productDescription;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * notifyURL;
@property(nonatomic, copy) NSString * signedString;
@property(nonatomic, copy) NSString * appID;
@property(nonatomic, copy) NSString * noncestr;
@property(nonatomic, copy) NSString * prepayid;

- (instancetype)initWithDictionary:(NSDictionary *)dicData;

@end
