//
//  TSGeocodeOperation.h
//  Memento
//
//  Created by Benoit Nolens on 02/12/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "TSOfflineLocation.h"

typedef void (^TSCompletionBlock)(NSDictionary *results, NSError *error);
static NSString const *kTSReturnValueAutocomplete = @"autoComplete";
static NSString const *kTSReturnValueData = @"data";

@interface TSGeocodeOperation : NSOperation

@property (nonatomic, strong) NSString *addressString;
@property (nonatomic, strong, readonly) NSArray *geoData;
@property (nonatomic) BOOL onlineFallbackEnabled;
@property (nonatomic) BOOL cacheEnabled;
@property (nonatomic) NSUInteger maxResults;
@property (nonatomic, copy) TSCompletionBlock resultBlock;


/**
 
 This method finds a city (TSOfflineLocation) using a a CLLocation object. This completelly offline.
 
 @param location The coordinates to use as a query to find the corresponding city.
 @param competionHandler The completion block that will be executed when a result has been found. The result object (TSOfflineLocation) will be pass through this block as a parameter.
 
 */
- (void)geocodeCoordinates:(CLLocation*)location completionHandler:(TSCompletionBlock)completionBlock;

/**
 
 This method returns the NSTimeZone of a specific CLLocation
 
 @param location The coordinates to use as a query to find the corresponding NSTimeZone.
 @return NSTimeZone The timezone information of a specific location
 
 */
- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location;

/**
 
 This method returns the NSTimeZone of a specific CLLocation our countryCode
 
 @param location The coordinates to use as a query to find the corresponding NSTimeZone.
 @param countryCode The country code that should be used as a query to find the correct location
 @return NSTimeZone The timezone information of a specific location
 
 */
- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location countryCode:(NSString *)countryCode;


@end


@interface TSGeocodeOperation (offline)

- (NSDictionary*)searchOfflineWithString:(NSString*)string;

@end


@interface TSGeocodeOperation (online)

- (void)searchOnlineWithString:(NSString*)string
                           completeBlock:(TSCompletionBlock)completeBlock;

@end
