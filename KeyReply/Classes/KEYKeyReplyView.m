//
//  KEYKeyReplyView.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/17.
//

#import <WebKit/WebKit.h>
#import "KEYKeyReplyView.h"

#ifdef PRODUCTION
    //Actual production
    #define DEMO_URL                @"https://files.keyreply.com/demo/index.html"
#else
#ifdef DEBUG
    //Debug
    #define DEMO_URL                @"https://files.keyreply.com/demo/index.html"
#else
    //Staging, archive for private beta
    #define DEMO_URL                @"https://files.keyreply.com/demo/index.html"
#endif
#endif

#define SDK_URL_SCHEME              @"keyreplysdk://"

@interface KEYKeyReplyView() <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
@property (nonatomic, strong) WKWebView * webView;
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
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript * wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUserController = [[WKUserContentController alloc] init];
    [wkUserController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUserController;
    
    
    
    WKWebView * webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:wkWebConfig];
    webView.backgroundColor = [UIColor clearColor];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.clipsToBounds = NO;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:webView];
    self.webView = webView;
    
    //Load webview
    [self loadUrl:DEMO_URL];
}


#pragma mark - Helper Functions

- (void)loadUrl:(NSString *)urlString
{
    NSURL * url = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


#pragma mark - Interface to SDK

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable results, NSError * _Nullable error) {
        
    }];
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
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:titleString
            message:alertString
            preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //TODO: do something with the parameters
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //Handle special keyreplysdk:// url
    NSString * absUrl = navigationAction.request.URL.absoluteString;
    BOOL sdkCallback = [absUrl hasPrefix:SDK_URL_SCHEME];
    if (sdkCallback) {
        [self handleSDKcallback:navigationAction.request.URL];
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"didReceiveScriptMessage: %@", message);
}


#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@からの表示", hostString];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:sender preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"閉じる" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@からの表示", hostString];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:sender preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSString *hostString = webView.URL.host;
    NSString *sender = [NSString stringWithFormat:@"%@からの表示", hostString];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:sender preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
