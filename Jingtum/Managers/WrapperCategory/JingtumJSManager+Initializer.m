//
//  JingtumJSManager+Initializer.m
//  Jingtum
//
//  Created by sunbinbin on 14-10-9.
//  Copyright (c) 2014年 jingtum. All rights reserved.
//

#import "JingtumJSManager+Initializer.h"
#import "RPGlobals.h"

@implementation JingtumJSManager (Initializer)

#define HTML_BEGIN @"<!DOCTYPE html>\
<html lang=\"en\">\
<head>\
<meta charset=\"utf-8\">\
<title>Jingtum Lib Demo</title>"

#define HTML_END @"</head>\
<body>\
<h1>Jingtum Lib Demo</h1>\
</body>\
</html>"

-(NSString*)jingtumHTML
{
    NSMutableString * html = [NSMutableString stringWithString:HTML_BEGIN];
    
    NSString *path;
    NSString *contents;
    
    path = [[NSBundle mainBundle] pathForResource:GLOBAL_Jingtum_LIB_VERSION ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
//    NSLog(@"html1====%@",contents);
    path = nil;
    contents = nil;
    
    path = [[NSBundle mainBundle] pathForResource:@"sjcl4" ofType:@"js"];
//    NSLog(@"path=====%@",path);
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
//    NSLog(@"html3====%@",contents);
    path = nil;
    contents = nil;
    

    path = [[NSBundle mainBundle] pathForResource:@"jingtum-lib-wrapper" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
//    NSLog(@"html4====%@",contents);
    path = nil;
    contents = nil;
    
    [html appendString:HTML_END];
    
    //NSLog(@"%@: Jingtum HTML:\n%@", self.class.description, html);
    
    
    return html;
}

-(void)setupJavascriptBridge
{
#if defined(DEBUG)
        // DEBUG PURPOSES ONLY
        [WebViewJavascriptBridge enableLogging];
#endif
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
        //#warning Testing purposes only
        raise(1);
    }];
}

-(void)wrapperInitialize
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    NSString * html = [self jingtumHTML];
    [_webView loadHTMLString:html baseURL:nil];
    [self setupJavascriptBridge];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@: webView: shouldStartLoadWithRequest", self.class.description);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%@: webViewDidStartLoad", self.class.description);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%@: webViewDidStartLoad", self.class.description);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@: webView: didFailLoadWithError", self.class.description);
}



@end
