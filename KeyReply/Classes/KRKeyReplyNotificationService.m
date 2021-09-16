//
//  KRKeyReplyNotificationService.m
//  KeyReply
//
//  Created by Quoc Nguyen on 11/08/2021.
//  Copyright © 2021 KeyReply. All rights reserved.
//

#import <OneSignal/OneSignal.h>
#import "KRKeyReplyNotificationService.h"


@implementation KRKeyReplyNotificationService

+ (void)initWithLaunchOptions:(NSDictionary *)launchOptions withAppID:(NSString *)appID {
    [OneSignal initWithLaunchOptions:launchOptions];
    [OneSignal setAppId:appID];
}

+ (void)didCloseChatWidget {
    [OneSignal sendTag:@"isLeaveChatScreen" value:[NSString stringWithFormat: @"%@", [NSNumber numberWithBool: YES]]];
}

+ (void)didOpenChatWidget {
    [OneSignal sendTag:@"isLeaveChatScreen" value:[NSString stringWithFormat: @"%@", [NSNumber numberWithBool: NO]]];
}

@end
