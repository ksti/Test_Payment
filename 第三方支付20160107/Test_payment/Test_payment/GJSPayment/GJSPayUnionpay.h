//
//  GJSUnionpay.h
//  Test_payment
//
//  Created by forp on 15/11/27.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayProtocol.h"
#import "UPPayPlugin.h"

@interface GJSPayUnionpay : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

/**
 选中商品调用银联支付,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController;

@end
