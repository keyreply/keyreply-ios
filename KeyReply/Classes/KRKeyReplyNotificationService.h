//
//  KRKeyReplyNotificationService.h
//  KeyReply
//
//  Created by Quoc Nguyen on 11/08/2021.
//  Copyright © 2021 KeyReply. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRKeyReplyNotificationService : NSObject

+ (void)initWithLaunchOptions:(NSDictionary* _Nullable)launchOptions withAppID:(NSString* _Nonnull)appID;

+ (void)didCloseChatWidget;
+ (void)didOpenChatWidget;

@end
