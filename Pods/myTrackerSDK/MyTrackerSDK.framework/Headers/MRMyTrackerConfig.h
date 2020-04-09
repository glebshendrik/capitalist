//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MRRegion)
{
	MRRegionNotSet,
	MRRegionEu,
	MRRegionRu
};

typedef NS_ENUM(NSUInteger, MRLocationTrackingMode)
{
	MRLocationTrackingModeNone,
	MRLocationTrackingModeCached,
	MRLocationTrackingModeActive
};


@interface MRMyTrackerConfig : NSObject

/**
 @discussion Your tracker identifier.
 */
@property(nonatomic, readonly, copy) NSString *trackerId;

/**
 @discussion App launch tracking. YES by default.
 */
@property(nonatomic) BOOL trackLaunch;

/**
 @discussion If inApp purchase events should be tracked automatically. YES by default.
 */
@property(nonatomic) BOOL autotrackPurchase;

/**
 @discussion If YES tracker will collect environment information like device or iOS information. YES by default.
 */
@property(nonatomic) BOOL trackEnvironment;

/**
 @discussion An interval (in seconds) during which a new launch is not tracked and a session is not interrupted while app is in background. Possible values range: 30-7200 seconds. 30 sec by default.
 */
@property(nonatomic) NSTimeInterval launchTimeout;

/**
 @discussion An interval (in seconds) during which events will be accumulated locally on the device before sending to the server. Allowed values are: 1-86400 seconds (1 day). 900 sec by default.
 */
@property(nonatomic) NSTimeInterval bufferingPeriod;

/**
 @discussion An interval (in seconds) starting from application install/update during which any new event will be send to the server immediately, without local buffering. Default value is set to 0 (immediate sending is disabled), allowed values are 0-432000 seconds (5 days).
 */
@property(nonatomic) NSTimeInterval forcingPeriod;

/**
 @discussion Geolocation tracking. Tracking modes:
 MRLocationTrackingModeNone — location tracking is not available.
 MRLocationTrackingModeCached — system cached value is used.
 MRLocationTrackingModeActive — current location request is used (by default).
 No matter what the mode, myTracker can track user geolocation only if the app already has this permission.
 
 @discussion Geolocation tracking mode.
 */
@property(nonatomic) MRLocationTrackingMode locationTrackingMode;

/**
 @discussion URL of your proxy. Should be valid URL or will be replaced by default URL.
 */
@property(nonatomic, copy, nullable) NSString *proxyHost;

/**
 @discussion Current region. This property sets region of tracker server.
 Available values:
 MRRegionNotSet
 MRRegionEu
 MRRegionRu
 */
@property(nonatomic) MRRegion region;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
