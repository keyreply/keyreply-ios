//
//  KEYKeyReplyView.m
//  KeyReply
//
//  Created by Torin Nguyen on 11/29/17.
//

#import <WebKit/WebKit.h>
#import "KEYKeyReplyView.h"

#define DEMO_URL        @"https://files.keyreply.com/demo/index.html"

@interface KEYKeyReplyView() <WKNavigationDelegate, WKUIDelegate>
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
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
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


#pragma mark - WKUIDelegate

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
