//
//  MRMyTracker.h
//  myTrackerSDK 2.0.4
//
//  Created by Timur Voloshin on 17.06.16.
//  Copyright © 2016 Mail.ru Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <myTrackerSDK/MRMyTrackerParams.h>
#import <myTrackerSDK/MRMyTrackerConfig.h>
#import <myTrackerSDK/MRMyTrackerAttribution.h>

@class MRMyTrackerParams;
@class MRMyTrackerConfig;
@class SKProduct;
@class SKPaymentTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface MRMyTracker : NSObject

/**
 @discussion Set a delegate to receive the deferred deeplink. Delegate must implement MRMyTrackerAttributionDelegate protocol.
 
 @param delegate Sets delegate for attribution.
 */
+ (void)setAttributionDelegate:(nullable id <MRMyTrackerAttributionDelegate>)delegate;

/**
 @discussion Set up a queue for delegate methods execution. If queue is not set up delegate's methods would be called on the main queue.

 @param delegate Sets delegate for attribution.
 @param queue Queue on which delegate's methods wil invoke.
 */
+ (void)setAttributionDelegate:(nullable id <MRMyTrackerAttributionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue;

/**
 @discussion Debug on/off. NO by default.
 
 @param enabled Set YES to enable debug mode or NO to disable.
 */
+ (void)setDebugMode:(BOOL)enabled;

/**
 @discussion Get current status of debug mode.
 
 @return Current debug mode status.
 */
+ (BOOL)isDebugMode;

/**
 @discussion Get current version of MyTracker.
 
 @return Current version.
*/
+ (NSString *)trackerVersion;

/**
 @discussion Tracker parameters can be set up in MRMyTrackerParams class instance available through this property. It is important to set the parameter before tracking events to pass user identifier with every event.
 
 @return MRMyTrackerParams instance.
 */
+ (MRMyTrackerParams *)trackerParams;

/**
 @discussion Configuration can be set up in MRMyTrackerConfig class instance available through this property.
 
 @return MRMyTrackerConfig instance.
 */
+ (MRMyTrackerConfig *)trackerConfig;

/**
 @discussion Use to get current instance identifier. Don't use this method on the main queue.
 
 @return Current instance identifier.
 */
+ (NSString *)instanceId;

/**
 @discussion Setup MyTracker with SDK_KEY.
 
 @param trackerId NSString with tracker identifier.
 */
+ (void)setupTracker:(NSString *)trackerId;

/**
 @discussion By default, data is sent every 15 minutes. The interval can be changed to anywhere from 1 second to 1 day through the bufferingPeriod property. If the user has quit the app, the events will be sent during next launch. It is extremely important to analyse certain events as soon as possible, especially in the first sessions since installing the app. This method will force sends all stored data.
 */
+ (void)flush;

/**
 @discussion Any user defined event with a custom name.
 
 @param name Event name. Max name length — 64 chars.
 */
+ (void)trackEventWithName:(NSString *)name;

/**
 @discussion Any user defined event with a custom name. Any optional parameters can be passed with event as «key-value» by optional parameter eventParams. Max name, key or value length — 64 chars.
 
 @param name Event name.
 @param eventParams Event parameters presented as NSDictionary<NSString *, NSString *>*. Max key or value length — 64 chars.
 */
+ (void)trackEventWithName:(NSString *)name eventParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion Call the method right after user successfully authorized in the app and got a unique identifier.
 */
+ (void)trackLoginEvent;

/**
 @discussion Call the method right after user successfully authorized in the app and got a unique identifier. This parameter allows you to pass user identifier with tracked event and get reliable user statistics.
 
 @param eventParams Login event parameters. Max key or value length — 64 chars.
 */
+ (void)trackLoginEventWithParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion Call the method if current user has invited other user.
 */
+ (void)trackInviteEvent;

/**
 Call the method if current user was invited by other user.
 
 @param eventParams Any optional parameters can be passed with event as «key-value» by optional parameter eventParams. Max key or value length — 64 chars.
*/
+ (void)trackInviteEventWithParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion Call the method right after user registration completed.
*/
+ (void)trackRegistrationEvent;

/**
 @discussion Call the method right after user registration completed.
 
 @param eventParams Any optional parameters can be passed with event as «key-value» by optional parameter eventParams. Max key or value length — 64 chars.
*/
+ (void)trackRegistrationEventWithParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion All in app purchases will be tracked automatically, unless you manually change this behavior by setting autotrackPurchase property to «NO» (autotrackPurchase = NO). In this case, to track in app purchases you could use this method
 
 @param product Instance of SKProduct.
 @param transaction instance of SKPaymentTransaction.
*/
+ (void)trackPurchaseWithProduct:(SKProduct *)product transaction:(SKPaymentTransaction *)transaction;

/**
 @discussion All in app purchases will be tracked automatically, unless you manually change this behavior by setting autotrackPurchase property to «NO» (autotrackPurchase = NO). In this case, to track in app purchases you could use this method
 
 @param product Instance of SKProduct.
 @param transaction instance of SKPaymentTransaction.
 @param eventParams Any optional parameters can be passed with event as «key-value» by optional parameter eventParams. Max key or value length — 64 chars.
*/
+ (void)trackPurchaseWithProduct:(SKProduct *)product transaction:(SKPaymentTransaction *)transaction eventParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion Call the method when user achieve new level.
*/
+ (void)trackLevelAchieved;

/**
 @discussion Call the method when user achieve new level.
 
 @param level Achieved level, optional.
*/
+ (void)trackLevelAchievedWithLevel:(nullable NSNumber *)level;

/**
 @discussion Call the method when user achieve new level.
 
 @param level Achieved level, optional.
 @param eventParams  Any optional parameters can be passed with event as «key-value» by optional parameter eventParams. Max key or value length — 64 chars.
*/
+ (void)trackLevelAchievedWithLevel:(nullable NSNumber *)level eventParams:(nullable NSDictionary<NSString *, NSString *> *)eventParams;

/**
 @discussion Call the method from the -application:continueUserActivity:restorationHandler: method of UIApplicationDelegate to get deeplink if it exists and track appication open by deeplink. If deeplink exists and valid attributionDelegate would be called with MRMyTrackerAttribution instance which will contain correct deeplink.
 
 @param userActivity The activity object containing the data associated with the task the user was performing. Use the data to continue the user's activity in your iOS app.
 @param restorationHandler Block/Closure, use parameter from method of UIApplicationDelegate, optional.
 
 @return BOOL value.
*/
+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * _Nullable restorableObjects))restorationHandler;

/**
 @discussion Call the method from the -application:openURL:options: method of UIApplicationDelegate to get deeplink if it exists and track appication open by deeplink. If deeplink exists and valid attributionDelegate would be called with MRMyTrackerAttribution instance which will contain correct deeplink.
 
 @param url The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
 @param sourceApplication The bundle ID of the app that is requesting your app to open the URL.
 @param annotation A property list supplied by the source app to communicate information to the receiving app.
*/
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;

/**
 @discussion Call the method form the -application:openURL:options: method of UIApplicationDelegate to get deeplink if it exists and track appication open by deeplink. If deeplink exists and valid attributionDelegate would be called with MRMyTrackerAttribution instance which will contain correct deeplink.
 
 @param url The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
 @param options A dictionary of URL handling options. For information about the possible keys in this dictionary and how to handle them, see UIApplicationOpenURLOptionsKey. By default, the value of this parameter is an empty dictionary.
*/
+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
