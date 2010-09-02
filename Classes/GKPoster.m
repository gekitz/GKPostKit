//
//  GKPoster.m
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

#import "GKPoster.h"
#import "GKPostItem.h"
#import "GKAuthDialog.h"
#import "SMGlobals.h"

#import "GKFacebookItem.h"
#import "GKFacebookAuthDialog.h"

#import "GKTwitterItem.h"
#import "GKTwitterAuthDialog.h"

#import "OAAsynchronousDataFetcher.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OARequestParameter.h"
#import "OAMutableURLRequest.h"

#define kFBPostURL @"https://graph.facebook.com/me/feed?access_token=%@"

#define kGKArchiveKey @"GKArchivePosterKey"
#define kFacebookItemKey @"FBItemKey"
#define kTwitterItemKey @"TwitterItemKey"

@interface GKPoster(Private)

+ (NSString *)defaultArchivePath;
- (void)initialize;


//Auth
- (BOOL)twitterAuth;
- (BOOL)facebookAuth;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation GKPoster

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize delegate = mDelegate;
@synthesize authDialogTintColor = mTintColor;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (void)initialize{
	mPostRequest = [[BaseRequest alloc] init];
	[mPostRequest setDelegate:self];
}

- (BOOL)twitterAuth{
	if(mTwitterItem.accessToken == nil){
		GKTwitterAuthDialog *dialog = [[GKTwitterAuthDialog alloc] init];
		dialog.item = mTwitterItem;
		dialog.tintColor = mTintColor;
		dialog.delegate = self;
		[dialog show];
		SMSaveRelease(dialog);
		return YES;
	}
	return NO;
}

- (BOOL)facebookAuth{
	if(mFacebookItem.accessToken == nil){
		GKAuthDialog *dialog = [[GKFacebookAuthDialog alloc] init];
		dialog.item = mFacebookItem;
		dialog.tintColor = mTintColor;
		dialog.delegate = self;
		[dialog show];
		SMSaveRelease(dialog);
		return YES;
	}
	return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (id)init {
	if(self = [super init]) {
		mFacebookItem = [[GKFacebookItem alloc] init];
		mTwitterItem = [[GKTwitterItem alloc] init];
		[self initialize];
	}
	return self;
}

- (BOOL)authorizeTwitter{
	return ![self twitterAuth];
}

- (BOOL)authorizeFacebook{
	return ![self facebookAuth];
}

- (BOOL)postToFacebook:(NSMutableDictionary *)dict{
	
	mFacebookItem.postElements = dict;
	
	if([self facebookAuth])
		return NO;
	
	[mFacebookItem.postElements setObject:mFacebookItem.accessToken forKey:@"access_token"];
	
	NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:kFBPostURL,mFacebookItem.accessToken];
	
	for(NSString *key in [dict allKeys]){
		NSString *appendValue = [NSString stringWithFormat:@"&%@=%@",key, [dict objectForKey:key]];
		[urlString appendString:appendValue];
	}
	
	if([mPostRequest initialPostConnectionWithURLString:urlString withHeaderFields:dict])
		[mDelegate postingStarted];
	
	SMSaveRelease(urlString);
	
	return NO;
}

- (BOOL)postToTwitter:(NSString *)message{
	mTwitterItem.message = message;
	
	if([self twitterAuth])
		return NO;
	
	OAToken *accessToken = [[OAToken alloc] initWithKey:mTwitterItem.accessToken secret:mTwitterItem.accessTokenSecret];
	OAMutableURLRequest *oaPostRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
																	consumer:mTwitterItem.consumer
																	   token:accessToken
																	   realm:nil
														   signatureProvider:nil];
	
	[oaPostRequest setHTTPMethod:@"POST"];
	
	OARequestParameter *statusParam = [[OARequestParameter alloc] initWithName:@"status"
																		 value:mTwitterItem.message];
	NSArray *params = [NSArray arrayWithObjects:statusParam, nil];
	[oaPostRequest setParameters:params];
	[statusParam release];
	
	OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oaPostRequest
																						  delegate:self
																				 didFinishSelector:@selector(sendStatusTicket:didFinishWithData:)
																				   didFailSelector:@selector(sendStatusTicket:didFailWithError:)];	
	
	[fetcher start];
	[oaPostRequest release];
	
	
	return YES;
}

- (void)drillDown{
	[NSKeyedArchiver archiveRootObject:self toFile:[GKPoster defaultArchivePath]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding 

- (id)initWithCoder:(NSCoder *)aDecoder{
	if(self = [super init]){
		mFacebookItem = [[aDecoder decodeObjectForKey:kFacebookItemKey] retain];
		mTwitterItem = [[aDecoder decodeObjectForKey:kTwitterItemKey] retain];
		[self initialize];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:mFacebookItem forKey:kFacebookItemKey];
	[aCoder encodeObject:mTwitterItem forKey:kTwitterItemKey];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark GKAuthDialogDelegate Methods

- (void)authDialogSucceed:(GKAuthDialog *)dialog{
	
	[self drillDown];
	[mDelegate loginFinished];
	
	if([dialog.item isKindOfClass:[GKFacebookItem class]]){
		if(mFacebookItem.postElements != nil && [mFacebookItem.postElements count] > 0){
			[self postToFacebook:mFacebookItem.postElements];
		}
	}else if([dialog.item isKindOfClass:[GKTwitterItem class]]){
		if(mTwitterItem.message != nil){
			[self postToTwitter:mTwitterItem.message];
		}
	}
}

- (void)authDialog:(GKAuthDialog *)dialog failedWithError:(NSError *)error{
	
}

- (void)authDialogCanceled:(GKAuthDialog *)dialog{
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BaseRequestDelegate Methods

- (void)baseRequestFinished:(BaseRequest *)request{
	[mDelegate postingFinished];
}

- (void)baseRequest:(BaseRequest *)request failedWithError:(NSError *)error{
	SMLog(@"Error occured while Posting: %@",error);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark OAAsynchronousDataFetcherDelegate Methods

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data{
	if(ticket.didSucceed){
		[mDelegate postingFinished];	
	}
	else {
		SMLog(@"Twitter Failed: %@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	}

}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error{
	SMLog(@"Twitter Failed: %@",error);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	// release your members
	SMSaveRelease(mFacebookItem);
	SMSaveRelease(mTwitterItem);
	SMSaveRelease(mPostRequest);
	SMSaveRelease(mTintColor);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class Methods

+ (NSString *)defaultArchivePath {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *basePath = [paths objectAtIndex:0];
	NSString *settingsPath = [basePath stringByAppendingPathComponent:kGKArchiveKey];
	return settingsPath;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Singleton implementation

static GKPoster *instance = nil;

+ (GKPoster *)sharedInstance {
	@synchronized( self ) {
		if ( instance == nil ) {
			
			@try {
				instance = [NSKeyedUnarchiver unarchiveObjectWithFile:[GKPoster defaultArchivePath]];
			} @catch (NSException * e) {
				// silent catch, occurs only if the application was updated.
				SMLog(@"Couldn't unarchive");
				instance = nil;
			}
			
			if(!instance)
				instance = [[GKPoster alloc] init];
		}
	}
	return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (instance == nil) {
			instance = [super allocWithZone:zone];
			return instance;  // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;    
}

- (unsigned)retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

@end