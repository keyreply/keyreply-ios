//
//  KEYKeyReplyView.h
//  KeyReply
//
//  Created by Jeremy Pek on 11/10/18.
//  Copyright © 2018 Torin Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEYKeyReplyView : UIView

- (void)reload;
- (void)setAutoOpenOnStart:(BOOL)enabled;
- (BOOL)autoOpenOnStart;

- (void)setServerSetting:(NSString * _Nonnull)_serverSetting;
- (NSString * _Nonnull)serverSetting;
- (void)setUserSetting:(NSMutableDictionary* _Nonnull)user;
- (NSMutableDictionary * _Nonnull)userSetting;

- (void)openChatWindow;
- (void)closeChatWindow;
- (void)toggleChatWindow;
- (void)availableActions:(void (^ _Nullable)(NSString * _Nonnull actions))completionHandler;
- (void)sendMessage:(NSString * _Nonnull)message;
- (void)setEnvUrl:(NSString*)url;
@end
