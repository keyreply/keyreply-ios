//
//  KEYViewController.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/2017.
//  Copyright © 2020 KeyReply Pte Ltd. All rights reserved.
//

#import "KEYViewController.h"
#import "KEYKeyReplyView.h"

#define ENV_WEBCHAT_URL  @"https://domain.com/webchat/?mode=mobile"   //Replace with ENV URL of webchat
#define SERVER_URL       @"https://domain.com/server/"  // Replace with Server Setting

@interface KEYViewController ()

@property (nonatomic, weak) IBOutlet KEYKeyReplyView * chatView;
@property (nonatomic, assign) CGRect chatViewFrame;

@end

@implementation KEYViewController

- (void)viewDidLoad
{   
    [super viewDidLoad];

    [self setupChatView];
    [self configureUserSetting];
    
}

#pragma mark - Utils

- (void)setupChatView
{
    [self.chatView setEnvUrl: ENV_WEBCHAT_URL];
    [self.chatView setServerSetting: SERVER_URL];
    
    [self.chatView enableAppTokenConfiguredInSetting];
    [self.chatView setGenerateJWTFunc:@selector(getNewToken) fromObject:self];
    [self.chatView reload];
}

#pragma mark - Helper

/*
 * Configure User Setting with JWT
 */

- (void)configureUserSetting
{
    NSMutableDictionary * userDict = [[NSMutableDictionary alloc] init];
    [userDict setValue:[self getNewToken] forKey:@"JWT"];
    [self.chatView setUserSetting:userDict];
    [self.chatView reload];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString*)getNewToken {
//    generate the new token here
    return token;
}

#pragma mark - Actions

- (void)resize:(NSString *)toggle {
    if([toggle isEqualToString:@"true"]) {
        self.chatView.hidden = true;
        
        [UIView animateWithDuration:0 delay:0.1 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            self.chatView.frame = self.chatViewFrame;
        } completion:^(BOOL finished){
            self.chatView.hidden = false;
        }];
    } else {
        self.chatView.hidden = true;
        
        [UIView animateWithDuration:0 delay:0.3 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            CGRect newFrame = CGRectMake(1240,894,125,130);
            self.chatView.frame = newFrame;
        } completion:^(BOOL finished){

            self.chatView.hidden = false;
        }];
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
