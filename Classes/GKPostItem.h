//
//  GKPostItem.h
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

#import <Foundation/Foundation.h>
#import "SMGlobals.h"

@class OAConsumer;
@class OAToken;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 @class       GKPostItem
 @abstract  
 @discussion
 */
@interface GKPostItem : NSObject <NSCoding> {
	NSString *mAccessToken;
	NSString *mAccessTokenSecret;
	NSString *mOAVerifier;
	
	NSString *mCallbackURL;
	NSString *mAuthorizationURL;
	
	OAConsumer *mConsumer;
	OAToken *mRequestToken;
}

@property (nonatomic, readonly) OAConsumer *consumer;
@property (nonatomic, retain) OAToken *requestToken;

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *accessTokenSecret;
@property (nonatomic, copy) NSString *oaVerifier;

@property (nonatomic, readonly) NSString *callbackURL;
@property (nonatomic, readonly) NSString *authorizationURL;

- (NSString *)accessTokenURLForCode:(NSString *)code;

@end

