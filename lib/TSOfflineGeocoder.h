//
//  LocalPlacesManager.h
//  Memento
//
//  Created by Benoit Nolens on 12/06/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

@import Foundation;
@import MapKit;
#include "TSGeocodeOperation.h"

@interface TSOfflineGeocoder : NSOperationQueue

@property (nonatomic) BOOL onlineFallbackEnabled;
@property (nonatomic) BOOL cacheEnabled;
@property (nonatomic) NSUInteger maxResults;

/**
 
 This method finds a city (TSOfflineLocation) using a string. This works completelly offline with a online fallback if a connection is available.
 Example: addressString = 'SF' and it will find and create a TSOfflineLocation object with it's display name, coordinates, population, country code and timezone information.
 
 @param addressString The search query. (works only for cities atm)
 @param async Set to true to excecute in NSOperationQueue
 @param competionHandler The completion block that will be executed when a result has been found. The result object (NSDictonary) will be pass through this block as a parameter. The result dictonary is constructed with a "autoComplete" NSString and a "result" NSArray filled with TSOfflineLocation objects.
 
 */

- (void) geocodeAddressString:(NSString *)addressString async:(BOOL)async completionHandler:(TSCompletionBlock)completionBlock;

- (void)geocodeAddressString:(NSString*)addressString completionHandler:(TSCompletionBlock)completionBlock;


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


- (void)addToCache:(NSDictionary*)place;
- (void)emtyCache;

@end
