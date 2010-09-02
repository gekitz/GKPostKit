//
//  GKTwitterItem.m
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

#import "GKTwitterItem.h"
#import "GKPostKitGlobals.h"

#import "OAConsumer.h" 

#define kRequestTokenURL @"http://api.twitter.com/oauth/request_token"
#define kAuthorizeURL @"https://api.twitter.com/oauth/authorize?oauth_token="
#define kAccessTokenURL @"https://api.twitter.com/oauth/access_token"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKTwitterItem

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize message = mMessage;
@synthesize requestTokenURL = mRequestTokenURL;
@synthesize accessTokenURL = mAccessTokenURL;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		mCallbackURL = [[NSString stringWithFormat:kTwitterCallbackURL] copy];
		mRequestTokenURL = [[NSString stringWithFormat:kRequestTokenURL] copy];
		mAuthorizationURL = [[NSString stringWithFormat:kAuthorizeURL] copy];
		mAccessTokenURL = [[NSString stringWithFormat:kAccessTokenURL] copy];
		mConsumer = [[OAConsumer alloc] initWithKey:kTwitterConsumerKey secret:kTwitterConsumerSecret];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super initWithCoder:aDecoder]){
		mCallbackURL = [[NSString stringWithFormat:kTwitterCallbackURL] copy];
		mRequestTokenURL = [[NSString stringWithFormat:kRequestTokenURL] copy];
		mAuthorizationURL = [[NSString stringWithFormat:kAuthorizeURL] copy];
		mAccessTokenURL = [[NSString stringWithFormat:kAccessTokenURL] copy];
		mConsumer = [[OAConsumer alloc] initWithKey:kTwitterConsumerKey secret:kTwitterConsumerSecret];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[super encodeWithCoder:aCoder];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	SMSaveRelease(mMessage);
	[super dealloc];
}

@end