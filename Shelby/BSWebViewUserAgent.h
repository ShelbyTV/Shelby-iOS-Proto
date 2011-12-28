//
// http://blog.sallarp.com/iphone-ipad-get-user-agent-for-uiwebview/
//

#import <Foundation/Foundation.h>

@interface BSWebViewUserAgent : NSObject <UIWebViewDelegate> {
	NSString *userAgent;
	UIWebView *webView;
}

@property (nonatomic, retain) NSString *userAgent;
-(NSString*)userAgentString;
@end
