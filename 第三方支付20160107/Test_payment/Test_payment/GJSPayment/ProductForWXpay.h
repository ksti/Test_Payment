//
//  ProductForWXpay.h
//  Test_payment
//
//  Created by forp on 15/12/4.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductForWXpay : NSObject
/**
 *  测试商品信息封装在Product中,外部商户可以根据自己商品实际情况定义
 */
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *orderId;
@property(nonatomic, copy) NSString * notifyURL;

- (instancetype)initWithDictionary:(NSDictionary *)dicData;

@end
