//
//  WechatPayManager.h
//  Test_payment
//
//  Created by forp on 15/12/3.
//  Copyright © 2015年 forp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol WechatPayManagerDelegate <NSObject>

@optional

- (void)managerDidRecvPayReq:(PayReq *)request;

- (void)managerDidRecvPayResponse:(PayResp *)response;

//
- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;

@end

@interface WechatPayManager : NSObject <WXApiDelegate>

@property (nonatomic, assign) id<WechatPayManagerDelegate> delegate;

+ (instancetype)sharedManager;

@end
