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
@end
