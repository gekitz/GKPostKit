//
//  GKFacebookAuthDialog.m
//  PostKit
//
//  Created by georgkitz on 9/1/10.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "GKFacebookAuthDialog.h"
#import "GKPostItem.h"
#import "SMGlobals.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKFacebookAuthDialog


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		// Initialization code
		mAccessTokenRequest = [[BaseRequest alloc] init];
		[mAccessTokenRequest setDelegate:self];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Overridden Methods

/*
// Only override layoutSubviews: if it is necessary
// An empty implementation adversely affects performance during animation.
- (void)layoutSubviews {
    [super layoutSubviews];
    // layout code
}
*/


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSString *urlString = [[request URL] absoluteString];
	NSRange range = [urlString rangeOfString:mItem.callbackURL];
	
	SMLog(@"URLString = %@",urlString);
	
	if(range.location != NSNotFound && range.location == 0){
		SMLog(@"Hide Webview");
		
		NSRange codeRange = [urlString rangeOfString:@"code="];
		if(codeRange.location !=NSNotFound){
			
			NSString *code = [urlString substringFromIndex:codeRange.location + codeRange.length];
			SMLog(@"Code: %@",code);
			[mAccessTokenRequest initialConnectionWithURLString:[mItem accessTokenURLForCode:code]];
			mWebView.hidden = YES;
		}

	}
	return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	SMSaveRelease(mAccessTokenRequest);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BaseRequest Delegate

- (void)baseRequestFinished:(BaseRequest *)request{
	NSString *data = [[NSString alloc] initWithData:request.receivedData encoding:NSUTF8StringEncoding];
	SMLog(@"Data: %@",data);
	NSRange range = [data rangeOfString:@"access_token="];
	if(range.location != NSNotFound){
		
		mItem.accessToken = [data substringFromIndex:range.location + range.length];
		[mDelegate authDialogSucceed:self];
		
		[self hide];
		SMSaveRelease(data);
		
		return;
	}
	
	NSError *error = [NSError errorWithDomain:@"GK-AccessTokenNotFound" code:999 userInfo:nil];
	SMSaveRelease(data);
	[mDelegate authDialog:self failedWithError:error];
	[self hide];
}

- (void)baseRequest:(BaseRequest *)request failedWithError:(NSError *)error{
	SMLog(@"Error %@",error);
	[mDelegate authDialog:self failedWithError:error];
	[self hide];
}

@end
