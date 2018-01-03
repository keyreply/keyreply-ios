//
//  KEYViewController.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/2017.
//  Copyright (c) 2017 Torin Nguyen. All rights reserved.
//

#import "KEYViewController.h"
#import <KeyReply/KeyReply-umbrella.h>

@interface KEYViewController ()
@property (nonatomic, weak) IBOutlet KEYKeyReplyView * chatView;
@end

@implementation KEYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.chatView enableDebugMode];
    [self.chatView reload];
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

- (IBAction)onBtnDevelopment:(id)sender
{
    [self.chatView enableDebugMode];
    [self.chatView reload];
}

- (IBAction)onBtnStaging:(id)sender
{
    [self.chatView enableStagingMode];
    [self.chatView reload];
}

- (IBAction)onBtnProduction:(id)sender
{
    //Default
    [self.chatView enableProductionMode];
    [self.chatView reload];
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
