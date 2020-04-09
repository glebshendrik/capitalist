//
// Copyright (c) 2019 Mail.Ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MRMyTrackerAttribution;

@protocol MRMyTrackerAttributionDelegate <NSObject>

/**
 @discussion Implementation of this method will get MRMyTrackerAttribution instance as a parameter, use it to make correct behaviour of your application.
 
 @param attribution MRMyTrackerAttribution instance with deeplink.
 */
- (void)didReceiveAttribution:(MRMyTrackerAttribution *)attribution;

@end

@interface MRMyTrackerAttribution : NSObject

/**
 Contains deeplink as NSString. 
 */
@property(nonatomic, readonly, copy, nullable) NSString *deeplink;

+ (instancetype)attributionWithDeeplink:(NSString *)deeplink;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
