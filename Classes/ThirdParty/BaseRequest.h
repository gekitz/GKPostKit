//
//  BaseRequest.h
//  iradio
//
//  Created by georgkitz on 7/30/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMGlobals.h"

@protocol BaseRequestDelegate;
    

@interface BaseRequest : NSObject {
    
    id<BaseRequestDelegate> mDelegate;
    
	struct {
		unsigned int parseContentType:1;
	}mDataFlags;
	
    NSURLConnection *mConnection;
    NSMutableData *mReceivedData;
    NSString *mURLString;
    NSUInteger mStatusCode;
	
	NSString *mContentType;
}

@property (nonatomic, assign, getter = shouldParseContentType) BOOL parseContentType;
@property (nonatomic, readonly) NSString *contentType;

@property (nonatomic, assign) id<BaseRequestDelegate> delegate;
@property (nonatomic, readonly) NSMutableData *receivedData;

- (BOOL)initialConnectionWithURLString:(NSString *)URLString;
- (BOOL)initialConnectionWithURL:(NSURL *)URL;
- (BOOL)initialConnectionWithURLRequest:(NSURLRequest *)request;
- (void)cancelConnection;

@end

@protocol BaseRequestDelegate <NSObject>

- (void)baseRequestFinished:(BaseRequest *)request;
- (void)baseRequest:(BaseRequest *)request failedWithError:(NSError *)error;

@end