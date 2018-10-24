//
//  KEYViewController.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/2017.
//  Copyright (c) 2017 Torin Nguyen. All rights reserved.
//

#import "KEYViewController.h"
#import "KeyReply/KEYKeyReplyView.h"

@interface KEYViewController ()
@property (nonatomic, weak) IBOutlet KEYKeyReplyView * tabChatView;
@property (nonatomic, weak) IBOutlet KEYKeyReplyView * chatView;
@end

@implementation KEYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.chatView setServerSetting:@"https://keyreply-platform-demo-bot.azurewebsites.net"];
    [self.chatView reload];
    
    [self.tabChatView setServerSetting:@"https://keyreply-platform-demo-bot.azurewebsites.net"];
    [self.tabChatView reload];
    
    NSMutableDictionary * userDict = [[NSMutableDictionary alloc] init];
    [userDict setValue:@"bot1" forKey:@"name"];
    [userDict setValue:@"token" forKey:@"JWT"];
    [self.chatView setUserSetting:userDict];
    [[self view] bringSubviewToFront:self.chatView];
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
