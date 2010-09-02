//
//  GKTwitterAuthDialog.m
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

#import "GKTwitterAuthDialog.h"
#import "SMGlobals.h"
#import "GKTwitterItem.h"

#import "OAAsynchronousDataFetcher.h"
#import "OAServiceTicket.h"

@interface GKTwitterAuthDialog(Private)

- (void)fetchAccessToken;
- (void)fetchRequestToken;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKTwitterAuthDialog


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
- (void)setItem:(GKPostItem *)value{
	SMSaveRelease(mItem);
	mItem = [value retain];
	
	[self fetchRequestToken];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		// Initialization code
		
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
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark OAAsynchronousDataFetcherDelegate Methods

- (void)tokenRequestTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	
	if(ticket.didSucceed){
			NSString *responseBody = [[NSString alloc] initWithData:data
														   encoding:NSUTF8StringEncoding];
			mItem.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
			[responseBody release];
			
			NSString *accessTokenURL = [NSString stringWithFormat:@"%@%@",mItem.authorizationURL,mItem.requestToken.key];
			SMSaveRelease(mRequest);
			
			mRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:accessTokenURL]];
			[mWebView loadRequest:mRequest];
		}
}

- (void)tokenRequestTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error{
	SMLog(@"RequestTokenFetchFailed %@", error);
	[mDelegate authDialog:self failedWithError:error];
}

- (void)tokenAccessTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data{
	if(ticket.didSucceed){
		
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
		mItem.accessToken = token.key;
		mItem.accessTokenSecret = token.secret;
		
		[responseBody release];
		[mDelegate authDialogSucceed:self];
		[self hide];
	}
}

- (void)tokenAccessTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error{
	SMLog(@"AccessTokenFetchFailure %@", error);
	[mDelegate authDialog:self failedWithError:error];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (void)fetchAccessToken{
	OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(GKTwitterItem *)mItem accessTokenURL]]
																	consumer:mItem.consumer
																	   token:mItem.requestToken
																	   realm:nil   // our service provider doesn't specify a realm
														   signatureProvider:nil]; // use the default method, HMAC-SHA1
	
    [oRequest setHTTPMethod:@"POST"];
	
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																						  delegate:self
																				 didFinishSelector:@selector(tokenAccessTicket:didFinishWithData:)
																				   didFailSelector:@selector(tokenAccessTicket:didFailWithError:)];
	[fetcher start];
	[oRequest release];
}

- (void)fetchRequestToken{
	NSString *url = [(GKTwitterItem *)mItem requestTokenURL];
	mRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] 
											   consumer:mItem.consumer 
												  token:nil 
												  realm:nil 
									  signatureProvider:nil];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:mRequest
																						  delegate:self
																				 didFinishSelector:@selector(tokenRequestTicket:didFinishWithData:)
																				   didFailSelector:@selector(tokenRequestTicket:didFailWithError:)];
	[fetcher start];	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	SMLog(@"Should load %@",request.URL.absoluteString);
	
	if([request.URL.absoluteString rangeOfString:mItem.callbackURL].location != NSNotFound){
		NSMutableDictionary *queryParams = nil;
		if (request.URL.query != nil)
		{
			queryParams = [NSMutableDictionary dictionaryWithCapacity:0];
			NSArray *vars = [request.URL.query componentsSeparatedByString:@"&"];
			NSArray *parts;
			for(NSString *var in vars)
			{
				parts = [var componentsSeparatedByString:@"="];
				if (parts.count == 2)
					[queryParams setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
			}
		}
		
		mItem.oaVerifier = [queryParams objectForKey:@"oauth_verifier"];
		[self fetchAccessToken];
		return NO;
	}
	
	return YES;
}


@end
