//
//  GJSPayApplePayCUP.h
//  Test_payment
//
//  Created by forp on 16/2/18.
//  Copyright © 2016年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GJSPayProtocol.h"
#import "UPAPayPlugin.h"

@interface GJSPayApplePayCUP : NSObject

@property (nonatomic, weak) id<GJSPayProtocol> delegate;

/**
 选中商品通过银联调用Apple Pay,自定义Order
 */
- (void)actionPayOrder:(id<OrderItem>)customOrder viewController:(UIViewController *)viewController;

@end
