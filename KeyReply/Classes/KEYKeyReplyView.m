//
//  KEYKeyReplyView.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/17.
//

#import <WebKit/WebKit.h>
#import "KEYKeyReplyView.h"

#define PRODUCTION_URL                  @"https://files.keyreply.com/demo/index.html"
#define STAGING_URL                     @"https://files.keyreply.com/demo/index.html"
#define DEV_URL                         @"https://rightfrom.us/temp/keyreply/"
#define CUSTOM_USER_AGENT               @"KeyReplyiOSSDK"

#define SDK_URL_SCHEME                  @"keyreplysdk://"
#define DEFAULT_CLIENT_ID               @"5f6cc7e4e2"

#define ACTION_OPEN_CHAT_WINDOW         @"OPEN_CHAT_WINDOW"
#define ACTION_CLOSE_CHAT_WINDOW        @"CLOSE_CHAT_WINDOW"
#define ACTION_TOGGLE_CHAT_WINDOW       @"TOGGLE_CHAT_WINDOW"
#define ACTION_SEND_MESSAGE             @"SEND_MESSAGE"
#define ACTION_SEND_POSTBACK            @"SEND_POSTBACK"

#define ERROR_ALERT_TITLE               @"SDK Error"


@interface KEYKeyReplyView() <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, copy) NSString * webViewUrl;
@property (nonatomic, copy) NSString * aClientId;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) BOOL autoOpenOnStart;
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
    self.autoOpenOnStart = YES;
    
    //Default to production mode
    self.webViewUrl = PRODUCTION_URL;
    self.aClientId = DEFAULT_CLIENT_ID;
    
    NSString * jScript =
    @"var meta = document.createElement('meta'); " \
    "meta.setAttribute( 'name', 'viewport' ); " \
    "meta.setAttribute( 'content', 'width = device-width, initial-scale = 1.0, minimum-scale = 1.0, maximum-scale = 1.0, user-scalable = yes' ); " \
    "document.getElementsByTagName('head')[0].appendChild(meta)";
    WKUserScript * wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUserController = [[WKUserContentController alloc] init];
    [wkUserController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUserController;
    
    WKWebView * webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:wkWebConfig];
    webView.backgroundColor = [UIColor clearColor];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.clipsToBounds = YES;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 9.0, *))
        webView.customUserAgent = CUSTOM_USER_AGENT;
    [self addSubview:webView];
    self.webView = webView;
}

- (void)reload
{
    [self loadUrl:self.webViewUrl];
}


#pragma mark - Public Settings

- (void)enableDebugMode
{
    self.debugMode = YES;
    self.webViewUrl = DEV_URL;
}
- (void)enableStagingMode
{
    self.debugMode = YES;
    self.webViewUrl = STAGING_URL;
}
- (void)enableProductionMode
{
    self.debugMode = NO;
    self.webViewUrl = PRODUCTION_URL;
}

- (void)autoOpenOnStart:(BOOL)enabled
{
    self.autoOpenOnStart = enabled;
}

- (void)setClientId:(NSString *)clientId
{
    if (clientId == nil)
        return;
    if ([clientId length] < 5)
        return;
    self.aClientId = clientId;
}

- (NSString *)clientId
{
    return self.aClientId;
}


#pragma mark - Public Interfaces

- (void)openChatWindow
{
    [self performKeyReplyAction:ACTION_OPEN_CHAT_WINDOW parameter:nil completionHandler:^(id _Nullable results, NSError * _Nullable error) {

    }];
}

- (void)closeChatWindow
{
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


#pragma mark - Helper Functions

- (void)loadUrl:(NSString *)urlString
{
    urlString = [urlString stringByAppendingFormat:@"#%@", self.aClientId];
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
                                                        options:NSJSONReadingAllowFragments
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
        [self showAlertWithTitle:titleString message:alertString];
        return;
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
    BOOL isMainLoad = [webView.URL.absoluteString isEqualToString:self.webViewUrl];
    if (isMainLoad && self.autoOpenOnStart)
        [self openChatWindow];
}

- (void)handleNagivationError:(NSError *)error
{
    NSString * failingUrl = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
    NSLog(@"%@", failingUrl);
    
    BOOL unsupportedUrl = error.code == NSURLErrorUnsupportedURL;
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
