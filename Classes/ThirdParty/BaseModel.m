//
//  BaseModel.m
//  Qype
//
//  Created by georgkitz on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseModel.h"
#import "SMGlobals.h"
#import "CJSONDeserializer.h"



@implementation BaseModel

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark getter / setter

@synthesize data = mData;
@synthesize entity = mEntity;
@synthesize requestURL = mRequestURL;
@synthesize delegate = mDelegate;

- (BOOL)loaded{
	return mDataFlags.loaded;
}

- (BOOL)isFresh {
	return mDataFlags.fresh;
}

- (void)setFresh:(BOOL)value {
	mDataFlags.fresh = value;
}

- (void)setInvalidateAble:(BOOL)value{
	mDataFlags.invalidate = value;
}

- (BOOL)isInvalidateAble{
	return mDataFlags.invalidate;
}

- (void)setPaginationModel:(BOOL)value{
	mDataFlags.paginationModel = value;
}

- (BOOL)hasPaginationModel{
	return mDataFlags.paginationModel;
}

- (void)setLoading:(BOOL)value{
	mDataFlags.loading = value;
}

- (BOOL)isLoading{
	return mDataFlags.loading;
}

- (void)setAutoPrepareContent:(BOOL)value{
	mDataFlags.autoPrepareContent = value;
}

- (BOOL)shoudAutoPrepareContent{
	return mDataFlags.autoPrepareContent;
}

- (NSInteger)totalElementsInPagination{
	return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject Methods

- (id)init{
	if(self = [super init]){
		mRequest = [[BaseRequest alloc] init];
		[mRequest setDelegate:self];
		
		
		mDataFlags.autoPrepareContent = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateModel) name:kModelInvalidationNotification object:nil];
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management
- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	mDelegate = nil;
	mRequest.delegate = nil;
	SMSaveRelease(mData);
	SMSaveRelease(mEntity);
	SMSaveRelease(mRequestURL);
	SMSaveRelease(mRequest);
	SMSaveRelease(mPagination);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BaseModel Methods

- (void)invalidateModel{
	if(![self isInvalidateAble])
		return;
	SMSaveRelease(mEntity);
	mDataFlags.loaded = NO;
	mDataFlags.fresh = NO;
}

- (void)cancelRequest{
	[mRequest cancelConnection];
}

- (BOOL)performRequest{
	if(mRequestURL == nil)
		return NO;
	return [mRequest initialConnectionWithURLString:mRequestURL];
}

- (BOOL)performLoadNextRequest{
	mDataFlags.pagination = YES;
//	if(mPagination.hasMorePages == NO) 
//		return NO;
//	return [mRequest initializeConnection:mPagination.nextPageUrl];
	return 0;
}

- (void)prepareLoadedContent{
	//override point
}

- (BOOL)parseDataFromResponse:(NSDictionary *)resultDict{
	//override point
	return YES;
}

- (NSData *)trimData:(NSData *)data{
	NSString *plainString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString *trimmedString = [plainString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return [[[NSData alloc] initWithData:[trimmedString dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BaseRequestDelegate
- (void)baseRequestFinished:(BaseRequest *) request{
	mDataFlags.loaded = YES;
	mDataFlags.loading = NO;
	mDataFlags.fresh = YES;
	NSError *jsonError = nil;
	NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:[self trimData:[mRequest receivedData]]
																				   error:&jsonError];
	if([resultDict count] > 0 && jsonError == nil) {
		
		resultDict = [resultDict objectForKey:kOutputKey];
		
		mCode = [[resultDict objectForKey:kCodeKey] integerValue];
		SMSaveRelease(mMessage);
		mMessage = [[resultDict objectForKey:kMessageKey] copy];
		
		if((mCode != 1) && (mCode != 200)){
			SMLog(@"Request Failed: %d -- %@",mCode, mMessage);
			NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:mMessage, NSLocalizedDescriptionKey, nil];	
			NSError *newError = [[NSError alloc] initWithDomain:kStandardErrorDomain code:NSURLErrorUnknown userInfo:errorDict];		
			[mDelegate dataFailedLoading:self error:newError];
			SMSaveRelease(newError);
			return;
		}
      
		//Parse & Prepare Content
		if((![self parseDataFromResponse:resultDict]) && (mCode == 1)){
			mDataFlags.fresh = NO;
			return;
		}
    if ( mCode == 200) {
      [self parseDataFromResponse:resultDict];
    }
		
		if([self shoudAutoPrepareContent])
			[self prepareLoadedContent];

		if([self hasPaginationModel]){
			//[mPagination fillPaginationWith:resultLinks andTotalResultCount:resultCount];
//			[mDelegate dataChanged:self request:!mDataFlags.pagination morePages:mPagination.hasMorePages];
			[mDelegate dataChanged:self];
		}else {
			[mDelegate dataChanged:self];
		}

	} else if(jsonError != nil) {
		SMLog(@"%@ -- %@",self,jsonError);
		NSString *errorString = NSLocalizedString(@"internalServerErrorJSON",@"");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];	
		NSError *newError = [[NSError alloc] initWithDomain:kStandardErrorDomain code:NSURLErrorUnknown userInfo:errorDict];		
		[mDelegate dataFailedLoading:self error:newError];
		SMSaveRelease(newError);
	} else {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedDescriptionKey, 
								   NSLocalizedString(@"placeNotFound",@""), nil];
		NSError *error = [[NSError alloc] initWithDomain:kStandardErrorDomain 
													code:kStandardErrorCode 
												userInfo:errorDict];
		[mDelegate dataFailedLoading:self error:error];
		[error release];
	}
}

- (void)baseRequest:(BaseRequest *)request failedWithError:(NSError *)error {
	mDataFlags.fresh = NO;
	mDataFlags.loading = NO;
	[mDelegate dataFailedLoading:self error:error];
}
@end
