//
//  GKPostItem.m
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

#import "GKPostItem.h"
#import "OAConsumer.h"
#import "OAToken.h"

#define kAccessToken @"accessToken"
#define kAccessTokenSecret @"accessTokenSecret"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKPostItem

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize accessToken = mAccessToken, callbackURL = mCallbackURL, authorizationURL = mAuthorizationURL, 
	requestToken = mRequestToken, consumer = mConsumer, accessTokenSecret = mAccessTokenSecret, oaVerifier = mOAVerifier;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		// implement your init method
		
	}
	return self;
}

- (NSString *)accessTokenURLForCode:(NSString *)code{
	//Override Point
	return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCodeing Protocol

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super init]){
		mAccessToken = [[aDecoder decodeObjectForKey:kAccessToken] copy];
		mAccessTokenSecret = [[aDecoder decodeObjectForKey:kAccessTokenSecret] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:mAccessToken forKey:kAccessToken];
	[aCoder encodeObject:mAccessTokenSecret forKey:kAccessTokenSecret];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	SMSaveRelease(mAccessToken);
	SMSaveRelease(mAccessTokenSecret);
	SMSaveRelease(mCallbackURL);
	SMSaveRelease(mAuthorizationURL);
	[super dealloc];
}

@end