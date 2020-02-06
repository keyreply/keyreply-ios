//
//  KEYViewController.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/2017.
//  Copyright (c) 2017 Torin Nguyen. All rights reserved.
//

#import "KEYViewController.h"
//#import "KeyReply/KEYKeyReplyView.h"
#import "KEYKeyReplyView.h"

@interface KEYViewController ()
@property (nonatomic, weak) IBOutlet KEYKeyReplyView * tabChatView;
@property (nonatomic, weak) IBOutlet KEYKeyReplyView * chatView;
@property (nonatomic, assign) CGRect chatViewFrame;
@end

@implementation KEYViewController

- (void)viewDidLoad
{   
    [super viewDidLoad];
    NSMutableDictionary * generator = [[NSMutableDictionary alloc] init];
    [generator setValue:@"http://localhost:3000/api/authorize_webchat" forKey:@"url"];
    [generator setValue:@"POST" forKey:@"method"];
    [generator setValue:@"data.access_token" forKey:@"accessTokenPath"];
    [self.chatView setTokenGeneratorSetting:generator];
    
    [self.chatView setEnvUrl:@"http://localhost:8081"];
//        [self.chatView setEnvUrl:@"https://mobile.keyreply.com"];
//    [self.chatView setServerSetting:@"https://demo-01.app.keyreply.com/server/"];
    [self.chatView setServerSetting:@"http://localhost:3000"];
    [self.chatView reload];
    [self.tabChatView setEnvUrl:@"https://rightfrom.us/temp/keyreply/"];
    [self.tabChatView setServerSetting:@"https://keyreply-platform-demo-bot.azurewebsites.net"];
    [self.tabChatView reload];
    NSMutableDictionary * userDict = [[NSMutableDictionary alloc] init];
    [userDict setValue:@"bot1" forKey:@"name"];
//    [userDict setValue:@"token" forKey:@"JWT"];
    [self.chatView setUserSetting:userDict];
    [[self view] bringSubviewToFront:self.chatView];
    [self.chatView setChatWindowResizeFunc:@selector(resize:) fromObject:self];
    self.chatViewFrame = self.chatView.frame;
    CGRect newFrame = CGRectMake(1240,894,125,130);
    self.chatView.frame = newFrame;
}

#pragma mark - Helper

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Actions
- (void)resize:(NSString *)toggle{
    if([toggle isEqualToString:@"true"]) {
        self.chatView.hidden = true;
        
        [UIView animateWithDuration:0 delay:0.1 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            self.chatView.frame = self.chatViewFrame;
        } completion:^(BOOL finished){
            self.chatView.hidden = false;
        }];
    }else {
        self.chatView.hidden = true;
        
        [UIView animateWithDuration:0 delay:0.3 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            CGRect newFrame = CGRectMake(1240,894,125,130);
            self.chatView.frame = newFrame;
        } completion:^(BOOL finished){

            self.chatView.hidden = false;
        }];
//        CGRect newFrame = CGRectMake(1240,894,125,130);
//        self.chatView.frame = newFrame;
    }
}
- (IBAction)onBtnOpen:(id)sender
{
    [self.chatView openChatWindow];
}

- (IBAction)onBtnClose:(id)sender
{
    [self.chatView closeChatWindow];
}

- (IBAction)onBtnSendMessage:(id)sender
{
    [self.chatView sendMessage:@"hello world"];
}

- (IBAction)onBtnActions:(id)sender
{
    //Default
    [self.chatView availableActions:^(NSString *actions) {
        [self showAlertWithTitle:nil message:actions];
    }];
}

@end
