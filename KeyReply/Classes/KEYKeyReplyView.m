//
//  KEYKeyReplyView.m
//  KeyReply_Example
//
//  Created by Jeremy Pek on 11/10/18.
//  Copyright © 2018 Torin Nguyen. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "KEYKeyReplyView.h"

#define CUSTOM_USER_AGENT               @"KeyReplyiOSSDK"

#define SDK_URL_SCHEME                  @"keyreplysdk://"
#define DEFAULT_ENV_URL                 @"https://mobile.keyreply.com/"

#define ACTION_OPEN_CHAT_WINDOW         @"OPEN_CHAT_WINDOW"
#define ACTION_CLOSE_CHAT_WINDOW        @"CLOSE_CHAT_WINDOW"
#define ACTION_TOGGLE_CHAT_WINDOW       @"TOGGLE_CHAT_WINDOW"
#define ACTION_SEND_MESSAGE             @"SEND_MESSAGE"
#define ACTION_SEND_POSTBACK            @"SEND_POSTBACK"
#define ACTION_INITIALIZE               @"INITIALIZE"

#define ERROR_ALERT_TITLE               @"SDK Error"


@interface KEYKeyReplyView() <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, copy) NSString * webViewUrl;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) BOOL aAutoOpenOnStart;
@property (nonatomic, strong) NSMutableDictionary * settingDict;
@property (nonatomic, assign) SEL generateJWTfunc;
@property (nonatomic, assign) SEL resizefunc;
@property (nonatomic, assign) NSObject * parent;
@end

@implementation KEYKeyReplyView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self == nil)
        return nil;
    
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.debugMode = NO;
    self.aAutoOpenOnStart = NO;
//    self.backgroundColor = [UIColor clearColor];
    //Default env_url
    self.webViewUrl = DEFAULT_ENV_URL;
    NSString * jScript =
    @"var meta = document.createElement('meta'); " \
    "meta.setAttribute( 'name', 'viewport' ); " \
    "meta.setAttribute( 'content', 'width = device-width, initial-scale = 1.0, minimum-scale = 1.0, maximum-scale = 1.0, user-scalable = yes' ); " \
    "document.getElementsByTagName('head')[0].appendChild(meta)";
    WKUserScript * wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUserController = [[WKUserContentController alloc] init];
    [wkUserController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    [wkUserController addScriptMessageHandler:self name:@"notification"];
    wkWebConfig.userContentController = wkUserController;
    
    WKWebView * webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:wkWebConfig];
//    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.clipsToBounds = NO;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
//    webView.scrollView.backgroundColor = [UIColor clearColor];
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 9.0, *))
        webView.customUserAgent = CUSTOM_USER_AGENT;
    [self addSubview:webView];
    self.webView = webView;
    self.settingDict = [NSMutableDictionary dictionary];
    [self clearCache];
}

- (void)reload
{
    [self loadUrl:[self.webViewUrl stringByAppendingString:@"/?manual=true"]];
}

#pragma mark - Public Settings

-(void) setEnvUrl:(NSString*)url {
    self.webViewUrl = url;
}

- (void)setAutoOpenOnStart:(BOOL)enabled
{
    self.aAutoOpenOnStart = enabled;
}

- (BOOL)autoOpenOnStart
{
    return self.aAutoOpenOnStart;
}

- (void)setServerSetting:(NSString*)url
{
    [self.settingDict setObject:url forKey:@"server"];
}

- (NSString *)serverSetting
{
    return self.settingDict[@"server"];
}

- (void)setUserSetting:(NSMutableDictionary*)user
{
    [self.settingDict setObject:user forKey:@"user"];
}

- (NSMutableDictionary *)userSetting
{
    return self.settingDict[@"user"];
}

- (void)enableAppTokenConfiguredInSetting;
{
    [self.settingDict setObject:[NSNumber numberWithBool:YES] forKey:@"appTokenConfigured"];
}


#pragma mark - Public Interfaces
-(void) clearCache {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
        for (WKWebsiteDataRecord *record  in records)
        {
            if ( [record.displayName containsString:@"keyreply"])
            {
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                          forDataRecords:@[record]
                                                       completionHandler:^{
                                                           NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                       }];
            }
        }
    }];
}

-(BOOL)verifyJWT {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* serverUrl = [self serverSetting];
    NSString* apiUrl = [serverUrl stringByAppendingString:@"/api/verify_token"];
    // get token from usersetting
    NSMutableDictionary * userDict = [self userSetting];
    NSString* token = [userDict valueForKey:@"JWT"];
    NSDictionary *userDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:token, @"token", nil];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:NSJSONWritingPrettyPrinted error: &error];
    // setting request params
    [request setURL:[NSURL URLWithString:apiUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSHTTPURLResponse* urlResponse = nil; //Response
    NSError *err = [[NSError alloc] init];  //Allocate error
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&err];
    NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    if([dataString isEqualToString:@"Bad Request"]) { //invalid token
        return false;
    }else {
        return true;
    }
}
//new method >>
-(void)setInitWithJWT:(NSString*)jwttoken {
    NSMutableDictionary * userDict = self.settingDict[@"user"];
    [userDict setValue:jwttoken forKey:@"JWT"];
    [self setUserSetting:userDict];
    
    NSString * payloadJsonString = [self convertDictionaryToString:self.settingDict];
    [self performKeyReplyAction:ACTION_INITIALIZE parameter:payloadJsonString completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
}

-(NSString *)generateJWT {
    if(self.generateJWTfunc) {
        return [self.parent performSelector:self.generateJWTfunc];
    }
    return @"";
}

- (void)setGenerateJWTFunc:(SEL)func fromObject:(id) object{
    self.generateJWTfunc = func;
    self.parent = object;
}

- (void)setChatWindowResizeFunc:(SEL)func fromObject:(id) object{
    self.resizefunc = func;
    self.parent = object;
}

- (void)openChatWindow
{
    if(self.resizefunc) {
        [self.parent performSelector:self.resizefunc withObject:@"true"];
    }
    [self performKeyReplyAction:ACTION_OPEN_CHAT_WINDOW parameter:nil completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
}

- (void)closeChatWindow
{
    if(self.resizefunc) {
        [self.parent performSelector:self.resizefunc withObject:@"false"];
    }
    [self performKeyReplyAction:ACTION_CLOSE_CHAT_WINDOW parameter:nil completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
}

- (void)toggleChatWindow
{
    [self performKeyReplyAction:ACTION_TOGGLE_CHAT_WINDOW parameter:nil completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
}

- (void)sendMessage:(NSString *)message
{
    if ([message length] <= 0)
        return;
    
    NSDictionary * payload = @{@"text":message};
    NSString * payloadJsonString = [self convertDictionaryToString:payload];
    if ([payloadJsonString length] < 5)
        return;
    
    [self performKeyReplyAction:ACTION_SEND_MESSAGE parameter:payloadJsonString completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
}

- (void)availableActions:(void (^ _Nullable)(NSString * actions))completionHandler
{
    [self evaluateJavaScript:@"$keyreply.actions" completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        if (error) {
            [self showAlertWithTitle:ERROR_ALERT_TITLE message:[error localizedDescription]];
            completionHandler(nil);
            return;
        }
        
        if (results == nil) {
            [self showAlertWithTitle:@"No available actions" message:[error localizedDescription]];
            if (completionHandler)
                completionHandler(nil);
            return;
        }
        
        NSString * resultString = [NSString stringWithFormat:@"%@", results];
        if (completionHandler)
            completionHandler(resultString);
    }];
}

- (void)renewJWT
{
    NSString* newJWT = [self generateJWT];
    NSDictionary * payload = @{@"jwt": newJWT};
    NSString * tokenToSet = [self convertDictionaryToString:payload];
    
    [self performKeyReplyAction:@"SET_JWT_RESEND_REQUEST" parameter:tokenToSet completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        NSLog(@"renewJWT error:\n%@", error);
    }];
}

-(void) initiateWebChat {
    if(self.settingDict[@"server"] == nil) {
        NSException *e = [NSException
                          exceptionWithName:@"ServerSettingNotFoundException"
                          reason:@"ServerSetting Not Found on System"
                          userInfo:nil];
        @throw e;
    }
    
    NSMutableDictionary * userDict = [self userSetting];
    NSString* token = [userDict valueForKey:@"JWT"];
    
    if(token != nil && ![self verifyJWT]) {
        [self generateJWT]; // async method which will complete and call 
    }else {
        NSString * payloadJsonString = [self convertDictionaryToString:self.settingDict];
        [self performKeyReplyAction:ACTION_INITIALIZE parameter:payloadJsonString completionHandler:^(id _Nullable results, NSError * _Nullable error) {
            NSLog(@"Init error:\n%@", error);
        }];
    }
    
}


#pragma mark - Helper Functions

- (void)loadUrl:(NSString *)urlString
{
    NSURL * url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                              message:message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)convertDictionaryToString:(NSDictionary *)dict
{
    //it takes dic, array, primitive types only. giving error if custom object.
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    NSString * nsJson = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
    return nsJson;
}


#pragma mark - Interface to SDK
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id results, NSError * _Nullable error))completionHandler
{
    if (self.debugMode)
        NSLog(@"Executing Javascript:\n%@", javaScriptString);
    
    BOOL isDebugLog = self.debugMode;
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        if (isDebugLog && results != nil)
            NSLog(@"%@", results);
        if (isDebugLog && error != nil)
            NSLog(@"%@", error);
        if (completionHandler)
            completionHandler(results, error);
    }];
}

- (void)performKeyReplyAction:(NSString *)action parameter:(NSString *)parameter completionHandler:(void (^ _Nullable)(_Nullable id results, NSError * _Nullable error))completionHandler
{
    NSString * jsString = nil;
    if ([parameter length] > 0)
        jsString = [NSString stringWithFormat:@"$keyreply.dispatch('%@', %@)", action, parameter];
    else
        jsString = [NSString stringWithFormat:@"$keyreply.dispatch('%@')", action];
    [self evaluateJavaScript:jsString completionHandler:completionHandler];
}


#pragma mark - Callback from SDK

- (void)handleSDKcallback:(NSURL *)url
{
    //Convert the query parameters in the URL to an NSDictionary
    NSString * query = [url query];
    NSArray * components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    for (NSString * component in components) {
        NSArray * subcomponents = [component componentsSeparatedByString:@"="];
        if ([subcomponents count] >= 2)
            [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Alert command
    NSString * alertString = [parameters objectForKey:@"alert"];
    if ([alertString length] > 0) {
        NSString * titleString = [parameters objectForKey:@"title"];
        if([titleString length] > 0) {
            [self showAlertWithTitle:titleString message:alertString];
        }
        if([alertString isEqualToString:@"open"]) {
            [self openChatWindow];
        }
        if([alertString isEqualToString:@"close"]) {
            [self closeChatWindow];
        }
        if([alertString isEqualToString:@"jwtexpired"]) {
            [self renewJWT];
        }
    }
    //TODO: do something with the parameters
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString * absUrl = navigationAction.request.URL.absoluteString;
    
    //Get this out of the way first
    if ([absUrl isEqualToString:self.webViewUrl]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    //Handle special keyreplysdk:// url
    BOOL sdkCallback = [absUrl hasPrefix:SDK_URL_SCHEME];
    if (sdkCallback) {
        BOOL sdkCallbackNewTab = [absUrl containsString:@"tab"];
        if(sdkCallbackNewTab) {
            NSArray *items =[absUrl componentsSeparatedByString:@"tab="];;
            NSString *urlString = [items objectAtIndex:1];
            NSURL* url =[NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        [self handleSDKcallback:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self handleNagivationError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self handleNagivationError:error];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    //    BOOL isMainLoad = [webView.URL.absoluteString isEqualToString:self.webViewUrl];
    //    if (isMainLoad && self.aAutoOpenOnStart)
        [self initiateWebChat];
    if (self.aAutoOpenOnStart) {
        [self openChatWindow];
    }
}

- (void)handleNagivationError:(NSError *)error
{
    NSString * failingUrl = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
    NSLog(@"%@", failingUrl);
    
    BOOL isUnsecured = [failingUrl rangeOfString:@"https://"].location == NSNotFound;
    
    if (isUnsecured) {
        [self showAlertWithTitle:@"Unsecured URL" message:failingUrl];
    }
    else {
        [self showAlertWithTitle:@"Unsupported URL" message:failingUrl];
    }
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"didReceiveScriptMessage: %@", message);
}


#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    [self showAlertWithTitle:nil message:message];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
}


/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
 @param webView The web view invoking the delegate method.
 @discussion Your app should remove the web view from the view hierarchy and update
 the UI as needed, such as by closing the containing browser tab or window.
 */
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0))
{
    [self.webView removeFromSuperview];
    [self removeFromSuperview];
    self.webView = nil;
}

@end

