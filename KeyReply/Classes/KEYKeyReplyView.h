//
//  KEYKeyReplyView.h
//  KeyReply
//
//  Created by Jeremy Pek on 11/10/18.
//  Copyright © 2018 KeyReply. All rights reserved.
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
- (void)enableAppTokenConfiguredInSetting;
- (void)renewJWT:(NSString*_Nonnull)newJWT;

- (void)openChatWindow;
- (void)closeChatWindow;
- (void)toggleChatWindow;
- (void)availableActions:(void (^ _Nullable)(NSString * _Nonnull actions))completionHandler;
- (void)sendMessage:(NSString * _Nonnull)message;
- (void)setEnvUrl:(NSString*_Nonnull)url;
- (void)setChatWindowResizeFunc:(SEL _Nonnull)func fromObject:(id _Nonnull) object;
- (void)setGenerateJWTFunc:(SEL _Nonnull)func fromObject:(id _Nonnull) object;

//new method >>
-(void)setInitWithJWT:(NSString*_Nonnull)jwttoken;

@end
