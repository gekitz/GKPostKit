//
//  GKFacebookItem.m
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

#import "GKFacebookItem.h"
#import "GKPostKitGlobals.h"
#import "SMGlobals.h"

#define kFBAuthorizationURL @"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&display=touch&scope=publish_stream"
#define kFBRetrieveAccessTokenURL @"https://graph.facebook.com/oauth/access_token?client_id=%@&redirect_uri=%@&client_secret=%@&code=%@"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKFacebookItem

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize postElements = mPostElements;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		// implement your init method
		mCallbackURL = [[NSString stringWithFormat:kFBCallbackURL] copy];
		mAccessToken = nil;
		mAuthorizationURL = [[NSString stringWithFormat:kFBAuthorizationURL,kFBApiKey,mCallbackURL] copy];
	}
	return self;
}

- (NSString *)accessTokenURLForCode:(NSString *)code{
	return [NSString stringWithFormat:kFBRetrieveAccessTokenURL, kFBApiKey,mCallbackURL,kFBApiSecret,code];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super initWithCoder:aDecoder]){
		mCallbackURL = [[NSString stringWithFormat:kFBCallbackURL] copy];
		mAuthorizationURL = [[NSString stringWithFormat:kFBAuthorizationURL,kFBApiKey,mCallbackURL] copy];
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
	SMSaveRelease(mPostElements);
	[super dealloc];
}

@end