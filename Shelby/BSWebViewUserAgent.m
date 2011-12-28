//
//  http://blog.sallarp.com/iphone-ipad-get-user-agent-for-uiwebview/
//

#import "BSWebViewUserAgent.h"


@implementation BSWebViewUserAgent
@synthesize userAgent;

-(NSString*)userAgentString
{
	webView = [[UIWebView alloc] init];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    
	// Wait for the web view to load our bogus request and give us the secret user agent.
	while (self.userAgent == nil) 
	{
		// This executes another run loop. 
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
    
	return self.userAgent;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	self.userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
    
	// Return no, we don't care about executing an actual request.
	return NO;
}

- (void)dealloc 
{
	[webView release];
	[userAgent release];
	[super dealloc];
}
@end
