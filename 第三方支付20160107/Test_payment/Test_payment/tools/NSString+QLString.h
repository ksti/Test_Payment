//
//  NSString+QLString.h
//  WorkAssistant
//
//  Created by Shrek on 15/5/29.
//  Copyright (c) 2015年 com.homelife.manager.mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QLString)

+ (instancetype)getValidStringWithObject:(id)obj;
- (BOOL)isEmptyString;
+ (NSString *)jsonStringWithNSDictionary:(NSDictionary *)dict;
+ (NSData *)jsonDataWithNSDictionary:(NSDictionary *)dict;

@end
