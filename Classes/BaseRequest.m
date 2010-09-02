//
//  BaseRequest.m
//  iradio
//
//  Created by georgkitz on 7/30/10.
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

#import "BaseRequest.h"

@interface BaseRequest(Private)

- (void)releaseConnectionMembers;

@property (nonatomic, copy) NSString *mURLString;

@end

@implementation BaseRequest

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark getter / setter

@synthesize delegate = mDelegate;
@synthesize receivedData = mReceivedData;
@synthesize contentType = mContentType;

- (void)setURLString:(NSString *)value{
	SMSaveRelease(mURLString);
	mURLString = [value copy];
}

- (BOOL)shouldParseContentType{
	return mDataFlags.parseContentType;
}

- (void)setParseContentType:(BOOL)value{
	mDataFlags.parseContentType = value;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject Methods

- (id)init{
    if(self = [super init]){
        mConnection = nil;
        mReceivedData = nil;
        mURLString = nil;
        mStatusCode = 0;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private Methods

- (void)releaseConnectionMembers{
	SMSaveRelease(mReceivedData);
	SMSaveRelease(mConnection);
	SMSaveRelease(mURLString);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark public Methods

- (BOOL)initialConnectionWithURLString:(NSString *)URLString{
    NSString *decodedURL = [URLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	SMLog(@"%@ :: API URL: %@", self, decodedURL);
	NSString *cleanURL = [decodedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[self setURLString:cleanURL];
	
	// clear if necessary the connection member and cancel the old request if running
	if(mConnection) {
		[mConnection cancel];
		[self releaseConnectionMembers];
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:
									 [NSURL URLWithString:cleanURL]] autorelease];
	
	mConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(mConnection) {
		mReceivedData = [[NSMutableData data] retain];
		return YES;
	}
	return NO;
}

- (BOOL)initialConnectionWithURL:(NSURL *)URL;{
	SMLog(@"%@ :: Request URL: %@", self, [URL absoluteString]);
	[self setURLString:[URL absoluteString]];
	// clear if necessary the connection member and cancel the old request if running
	if(mConnection) {
		[mConnection cancel];
		[self releaseConnectionMembers];
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:URL] autorelease];
	
	mConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(mConnection) {
		mReceivedData = [[NSMutableData data] retain];
		return YES;
	}
	return NO;
}

- (BOOL)initialConnectionWithURLRequest:(NSURLRequest *)request{
	SMLog(@"%@ :: Request URL: %@", self, [[request URL] absoluteString]);
	[self setURLString:[[request URL] absoluteString]];
	// clear if necessary the connection member and cancel the old request if running
	if(mConnection) {
		[mConnection cancel];
		[self releaseConnectionMembers];
	}
	
	mConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(mConnection) {
		mReceivedData = [[NSMutableData data] retain];
		return YES;
	}
	return NO;
}

- (BOOL)initialPostConnectionWithURLString:(NSString *)URLString withHeaderFields:(NSDictionary *)values{
	NSString *decodedURL = [URLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	SMLog(@"%@ :: API URL: %@", self, decodedURL);
	NSString *cleanURL = [decodedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[self setURLString:cleanURL];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:
									 [NSURL URLWithString:cleanURL]] autorelease];
	
	[request setHTTPMethod:@"POST"];
	
	for(NSString *key in [values allKeys]){
		[request addValue:[values objectForKey:key] forHTTPHeaderField:key];
	}
	return [self initialConnectionWithURLRequest:request];
}

- (void)cancelConnection{
	if(mConnection != nil)
		[mConnection cancel];
	[self releaseConnectionMembers];
}

- (void)parseContentTypeForResponse:(NSHTTPURLResponse *)response{
	SMSaveRelease(mContentType);
	
	NSDictionary *headerFields = response.allHeaderFields;
	NSString *totalContentType = [headerFields objectForKey:@"Content-Type"];

	NSRange range = [totalContentType rangeOfString:@";"];
	if(range.location != NSNotFound){
		mContentType = [[totalContentType substringToIndex:range.location] retain];
	}else {
		mContentType = [totalContentType retain];
	}
	
	SMLog(@"Content-Type: %@", mContentType);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[mReceivedData appendData:data];
}	

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	
	if(httpResponse == nil)
		return;
	
	if(mDataFlags.parseContentType == YES)
		[self parseContentTypeForResponse:httpResponse];
	
	SMLog(@"StatusCode: %d", [httpResponse statusCode]);
	
	mStatusCode = [httpResponse statusCode];
	[mReceivedData setLength:0];
	
//	if(mStatusCode == 200 || mStatusCode == 500)
//		return;
//	
//	SMLog(@"Statuscode ERROR!!");
//	NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"internalServerError",@""), mStatusCode];
//	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
//	NSError *error =  [[NSError alloc] initWithDomain:kStandardErrorDomain code:kStandardErrorCode userInfo:errorDict];
//	
//	[mDelegate baseRequest:self failedWithError:error];
//	
//	[self cancelConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[mDelegate baseRequest:self failedWithError:error];
	[self cancelConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if(mStatusCode == 200){
		[mDelegate baseRequestFinished:self];
	}else{
		NSString *log = [[NSString alloc] initWithData:mReceivedData encoding:NSUTF8StringEncoding];
		SMLog(@"%@ -- %@",self, log);
		SMSaveRelease(log);
		[mDelegate baseRequest:self failedWithError:nil];
	}//else{
//		NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"internalServerError",@""), mStatusCode];
//		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
//		NSError *error =  [[NSError alloc] initWithDomain:kStandardErrorDomain code:kStandardErrorCode userInfo:errorDict];
//	
//		[mDelegate baseRequest:self failedWithError:error];
//	}
	[self releaseConnectionMembers];
}
@end
