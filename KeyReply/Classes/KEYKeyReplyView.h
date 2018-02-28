//
//  KEYKeyReplyView.h
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/17.
//

#import <UIKit/UIKit.h>

@interface KEYKeyReplyView : UIView

- (void)reload;
- (void)enableDebugMode;
- (void)enableStagingMode;
- (void)enableProductionMode;
- (void)autoOpenOnStart:(BOOL)enabled;

- (void)setClientId:(NSString *)clientId;
- (NSString *)clientId;

- (void)openChatWindow;
- (void)closeChatWindow;
- (void)toggleChatWindow;
- (void)availableActions:(void (^ _Nullable)(NSString * actions))completionHandler;
- (void)sendMessage:(NSString *)message;

@end
