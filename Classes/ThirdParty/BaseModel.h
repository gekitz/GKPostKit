//
//  BaseModel.h
//  Qype
//
//  Created by georgkitz on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"

@protocol BaseModelDelegate;

@class Entity;
@class QypePagination;

#define kResultKey @"results"
#define kResultLinksKey @"links"
#define kResultCountKey @"total_entries"
#define kOutputKey @"output"
#define kCodeKey @"code"
#define kMessageKey @"message"

@interface BaseModel : NSObject <BaseRequestDelegate>{
	NSMutableArray *mData;
	Entity *mEntity;
	NSString *mRequestURL;
	
	BaseRequest *mRequest;
	id<BaseModelDelegate> mDelegate;
	QypePagination *mPagination;
	
	struct  {
		unsigned int loaded:1;
		unsigned int fresh:1;
		unsigned int invalidate:1;
		unsigned int pagination:1;
		unsigned int paginationModel:1;
		unsigned int loading:1;
		unsigned int autoPrepareContent:1;
	}mDataFlags;
	
	NSInteger mCode;
	NSString *mMessage;
}

@property (nonatomic, readonly)BOOL loaded; //YES if the content is loaded
@property (nonatomic, assign, getter = isLoading) BOOL loading; //while loading data YES
@property (nonatomic, assign, getter = isFresh) BOOL fresh; //if data is fresh YES
@property (nonatomic, assign, getter = isInvalidateAble) BOOL invalidateAble; //indicates if the content is invalidatabele, default is NO
@property (nonatomic, assign, getter = hasPaginationModel) BOOL paginationModel; //indicates if the model is a model for paginated content, default is NO
@property (nonatomic, assign, getter = shoudAutoPrepareContent) BOOL autoPrepareContent; //indicates if the model should autoprepare the content (autoPrepareContent Method is called) default is YES

@property (nonatomic, readonly) NSMutableArray *data; //the loaded content
@property (nonatomic, retain) Entity *entity; //entity to load the content (user, place...)
@property (nonatomic, retain) NSString *requestURL; //the requestURL
@property (nonatomic, assign) id<BaseModelDelegate>delegate; 
@property (nonatomic, readonly)NSInteger totalElementsInPagination;


//--------------------------------------------------------------------------------------------------
/*!
 @method     invalidateModel
 @abstract   This method is called automatically if you set the property invalidateAble to YES, when the Notification QypeModelInvalidation
			 is posted. In this Method you should clean up your model.
 @discussion 
 */
- (void)invalidateModel;


//--------------------------------------------------------------------------------------------------
/*!
 @method     prepareLoadedContent
 @abstract   Should be implemented in derived classes. This method is called while the API result is handleda and only if the property autoPrepareContent is YES. 
			 In this method you should prepare the loaded content, for example, build the right array structure. 
 @discussion 
 */
- (void)prepareLoadedContent;


//--------------------------------------------------------------------------------------------------
/*!
 @method     parseDataFromResponse
 @abstract   Should be implemented in derived classes. This method called to parse the loaded content. 
 @discussion 
 */
- (BOOL)parseDataFromResponse:(NSDictionary *)jsonData;


//--------------------------------------------------------------------------------------------------
/*!
 @method     cancelRequest
 @abstract   This method cancels the current request
 @discussion 
 */
- (void)cancelRequest;


//--------------------------------------------------------------------------------------------------
/*!
 @method     performRequest
 @abstract   This method performs a request with the current requestURL
 @discussion 
 */
- (BOOL)performRequest;


//--------------------------------------------------------------------------------------------------
/*!
 @method     performLoadNextRequest
 @abstract   This method performs a pagination request with the next page
 @discussion 
 */
- (BOOL)performLoadNextRequest;

@end


@protocol BaseModelDelegate
@optional

//--------------------------------------------------------------------------------------------------
/*!
 @method     dataChanged
 @abstract   This method is called when the hasPaginationModel parameter is NO and the parsed result is ready for use.
 @discussion 
 */
- (void)dataChanged:(BaseModel *)baseModel;

//--------------------------------------------------------------------------------------------------
/*!
 @method     dataChanged:request:morePages:
 @abstract   This method is called when the hasPaginationModel parameter is YES and the parsed result is ready for use.
 @discussion 
 */
- (void)dataChanged:(BaseModel *)baseModel request:(BOOL)newRequest morePages:(BOOL)morePages;
@required


//--------------------------------------------------------------------------------------------------
/*!
 @method     dataFailedLoading:error:
 @abstract   This method is called when an error occurs
 @discussion 
 */
- (void)dataFailedLoading:(BaseModel *)baseModel error:(NSError *)localizedError;
@end