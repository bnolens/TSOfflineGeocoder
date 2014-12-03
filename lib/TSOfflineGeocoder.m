//
//  LocalPlacesManager.m
//  Memento
//
//  Created by Benoit Nolens on 12/06/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

#import "TSOfflineGeocoder.h"
#import "TSOfflineLocation.h"

@interface TSOfflineGeocoder ()

@property (nonatomic, strong, getter=geocodeOperation) TSGeocodeOperation *geocodeOperation;

@end


@implementation TSOfflineGeocoder

@synthesize onlineFallbackEnabled = _onlineFallbackEnabled, cacheEnabled = _cacheEnabled;

#pragma mark - Initialization

- (id)init {
    
    if (self = [super init]) {
        
        self.name = @"TSOfflineGeocoderThread";
        self.maxConcurrentOperationCount = 1;
        self.qualityOfService = NSQualityOfServiceUserInteractive;
        
        self.onlineFallbackEnabled = YES;
        self.cacheEnabled = YES;
        self.maxResults = 5;
    }
    
    return self;
}

#pragma mark - Getters / Setters

- (TSGeocodeOperation*) geocodeOperation {
    
    if (!_geocodeOperation) {
        _geocodeOperation = [TSGeocodeOperation new];
    }
    
    return _geocodeOperation;
}

#pragma mark - Public methods

- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location {
    
    return [self.geocodeOperation timeZoneWithLocation:location];
}

- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location countryCode:(NSString *)countryCode {
    
    return [self.geocodeOperation timeZoneWithLocation:location countryCode:countryCode];
}

- (void)geocodeCoordinates:(CLLocation*)location completionHandler:(TSCompletionBlock)completionBlock {
    
    [self.geocodeOperation geocodeCoordinates:location completionHandler:completionBlock];
}

- (void) geocodeAddressString:(NSString *)addressString async:(BOOL)async completionHandler:(TSCompletionBlock)completionBlock {
    
    if (self.operationCount > 0) {
        [self cancelAllOperations];
    }
    
    self.geocodeOperation = [TSGeocodeOperation new];
    self.geocodeOperation.addressString = addressString;
    self.geocodeOperation.resultBlock = [completionBlock copy];
    self.geocodeOperation.onlineFallbackEnabled = self.onlineFallbackEnabled;
    self.geocodeOperation.cacheEnabled = self.cacheEnabled;
    self.geocodeOperation.maxResults = self.maxResults;
    
    if (async) {
        [self addOperation:self.geocodeOperation];
    } else {
        [self.geocodeOperation start];
    }
}

- (void) geocodeAddressString:(NSString *)addressString completionHandler:(TSCompletionBlock)completionBlock {
    
    [self geocodeAddressString:addressString async:YES completionHandler:completionBlock];
}

- (void)addToCache:(NSDictionary *)place {
    
}

- (void)emtyCache {
    
}

@end
