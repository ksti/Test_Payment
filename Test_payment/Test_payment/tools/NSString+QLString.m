//
//  NSString+QLString.m
//  WorkAssistant
//
//  Created by Shrek on 15/5/29.
//  Copyright (c) 2015年 com.homelife.manager.mobile. All rights reserved.
//

#import "NSString+QLString.h"

@implementation NSString (QLString)

+ (instancetype)getValidStringWithObject:(id)obj {
    /**
     *  nil->(null)
     *  NSNull-><null>
     */
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *strValue = obj;
        if (strValue && ![strValue isEqualToString:@"<null>"] && ![strValue isEqualToString:@"(null)"] && ![strValue isEqualToString:@""]) {
            return strValue;
        } else {
            return @"";
        }
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", obj];
    } else {
        return @"";
    }
}

- (BOOL)isEmptyString {
    if ([self isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+ (NSString *)jsonStringWithNSDictionary:(NSDictionary *)dict{
    NSData *dataJson = [NSString jsonDataWithNSDictionary:dict];
    NSString *strJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
    return strJson;
}
+ (NSData *)jsonDataWithNSDictionary:(NSDictionary *)dict{
    NSError *error = nil;
    NSData *dataJson = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if(error) {
        NSAssert(0>1, @"解析JSONObject出错");
        return nil;
    } else {
        //QLLog(@"Serialization body: %@",dict);
        return dataJson;
    }
}

@end
