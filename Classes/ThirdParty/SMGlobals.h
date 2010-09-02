//
//  SMGlobals.h
//  iTranslate
//
//  Created by Richard Marktl on 10.08.09.
//  Copyright 2009 Sonico GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Shop Indentifier
#define kShopName @"name"
#define kShopAddress @"address"
#define kShopZip @"zip"
#define kShopCity @"city"
#define kShopCountry @"country"
#define kShopLatitude @"latitude"
#define kShopLongitude @"longitude"
#define kShopDistance @"distance"
#define kShopBusinessHours @"businesshours"
#define kShopTelephone @"telephone"
#define kShopFax @"fax"
#define kShopParkingInfo @"parking_info"
#define kShopFriseur @"frisoerstudio"
#define kShopKosmetikstudio @"kosmetikstudio"
#define kShopGesundePause @"gesunde_pause"
#define kShopHaarverlaengerung @"haarverlaengerung" 
#define kShopNagestudio @"nagelstudio"
#define kShopEmail @"email"

#define kKosmetikIndex 0
#define kFriseurstudioIndex 1
#define kNagestudioIndex 2
#define kGesundePauseIndex 3
#define kHaarverlIndex 4

#define kKosmetikStudio NSLocalizedString(@"kosmetik","")
#define kFriseurstudio NSLocalizedString(@"frisur","")
#define kNagelstudio NSLocalizedString(@"nagel","")
#define kGesundePause NSLocalizedString(@"pause","")
#define kHaarverl NSLocalizedString(@"haar","")


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Behaviour

#define DEBUG_API //comment following line to use live api

#ifdef DEBUG_API
#define API_URL @"http://alphadmapi.mobile-couponing.at"
#else
#define API_URL @"http://dmapi.mobile-couponing.at"
#endif

#define DEBUG // comment following line to disable logging messages

#ifdef DEBUG
#define SMLog NSLog
#else
#define SMLog    
#endif

#define SMWARN SMLog

#define SMLogRect(rect) \
SMLog(@"x = %4.f, y = %4.f, w = %4.f, h = %4.f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

#define SMLogPoint(pt) \
SMLog(@"x = %4.f, y = %4.f", pt.x, pt.y)

#define SMLogSize(size) \
SMLog(@"w = %4.f, h = %4.f", size.width, size.height)

#define SMSaveRelease(releasePointer) \
{ [releasePointer release]; releasePointer = nil; }

#define SMSaveCFRelease(releasePointer) \
{ CFRelease(releasePointer); releasePointer = NULL; }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Sizing Helpers

#define kTabBarHeight        49
#define kNavigationBarHeight 44
#define kToolbarHeight       44
#define kToolbarHeightLandScape 33

#define kLandScapeBounds     CGRectMake(  0,  0, 480, 320)
#define kLandScapeFrameLeft  CGRectMake( 30,  0, 300, 480)
#define kLandScapeFrameRight CGRectMake(-10,  0, 300, 480)

#define kPortraitFrame       CGRectMake(  0, 20, 320, 460)
#define kPortraitBounds      CGRectMake(  0,  0, 320, 460)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define HSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define HSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define DMTINT_COLOR RGBCOLOR(84,55,138)
#define DMTINT_COLOR_LIGHT RGBCOLOR(166,148,194)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// adjust helpers

#define ADJUST_ORIGIN(view,x,y) \
{ CGRect adjust = view.frame; adjust.origin.x = x; adjust.origin.y = y; view.frame = adjust; }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Animation Behaviour

#define kDefaultAnimationDuration 0.3 // default duration of the most iPhone view animations
#define kDefaultAlphaValue        0.8
#define kAccelerometerFrequency  20

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking Constants

typedef enum {
	SMURLRequestCachePolicyNoCache = 0, // always load from the web and don't cache it
	SMURLRequestCachePolicyNetwork = 1, // load from the the disk if possible otherwise from the web (invalidation age)
	SMURLRequestCachePolicyDisk    = 2 // load from the disk if only a short time expired otherwise from the web (experation age)
} SMURLRequestCachePolicy;

#define SMURLValidPolicy(o) ((o) & SMURLRequestCachePolicyNoCache || (o) & SMURLRequestCachePolicyNetwork || (o) & SMURLRequestCachePolicyDisk)

#define kPostTitleNotification @"titleNotification"
#define kPostTitleNotificationTitle @"titleNotificationTitle"
#define kPostUpdateStateNotification @"stateNotification"
#define kModelInvalidationNotification @"invalidateModel"

#define kAddStationNotification @"addStationNotification"
#define kAddStationNotificationStationKey @"addStationNotificationStationKey"
//Error
#define kStandardErrorDomain @"standardErrorDomain"
#define kStandardErrorCode 999

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Drawing Constants
enum {
    SMRoundedCornerNone        = 0,
    SMRoundedCornerTopLeft     = 1 << 0,
    SMRoundedCornerTopRight    = 1 << 1,
    SMRoundedCornerBottomLeft  = 1 << 2,
    SMRoundedCornerBottomRight = 1 << 3,
	SMRoundedCornerImage = (SMRoundedCornerTopLeft | SMRoundedCornerTopRight | SMRoundedCornerBottomLeft | SMRoundedCornerBottomRight)
};
typedef NSUInteger SMRoundedCorner;



