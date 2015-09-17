//
//  TSGeocodeOperation.m
//  Memento
//
//  Created by Benoit Nolens on 02/12/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

NSString *kTSReturnValueAutocomplete  = @"TSOfflineGeocoder.autoComplete";
NSString *kTSReturnValueData          = @"TSOfflineGeocoder.data";
static NSArray *geoDataStatic = nil;

#import "TSGeocodeOperation.h"

@interface TSGeocodeOperation ()

@property (nonatomic, strong) NSArray *geoData;
@property (nonatomic, strong) NSArray *geoDataSubset;
@property (nonatomic, strong) NSString *previousSearchQuery;

@end

@implementation TSGeocodeOperation

- (instancetype) init {
    
    if (self = [super init]) {
        [self loadLocalGeoData];
    }
    return self;
}

- (void) main {
    
    if(!self.cancelled) {
        NSDictionary *results = [self searchOfflineWithString:self.addressString];
        if (results && !self.cancelled) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
                if (!self.isCancelled) {
                    self.resultBlock(results, nil);
                }
            }];
            
        } else if(!self.cancelled) {
            if (self.onlineFallbackEnabled) {
                
                [self searchOnlineWithString:self.addressString completeBlock:^(NSDictionary *resultsDic, NSError *error) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
                        if (!self.isCancelled) {
                            self.resultBlock(resultsDic, error);
                        }
                    }];
                }];
                
            } else {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
                    if (!self.isCancelled) {
                        self.resultBlock(nil, nil);
                    }
                }];
            }
        }
    }
}

#pragma mark - Private methods

- (NSArray*) loadOfflineDBWithPathForResource:(NSString *)path ofType:(NSString *)type {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath =[bundle pathForResource:[NSString stringWithFormat:@"Database.bundle/%@", path] ofType:type];
    NSError *error;
    NSString *json = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    NSAssert(json.length != 0, @"TSOfflineGeocoder: TSOfflineGeocoder_geoData.json not found in app bundle");
    
    NSArray *JSON = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options: NSJSONReadingMutableContainers
                                                      error: &error];
    
    NSAssert(error == nil, @"TSOfflineGeocoder: JSON parsing failed");
    
    NSArray* results = [NSArray arrayWithArray:(NSArray *)JSON];
    JSON = nil;
    json = nil;
    filePath = nil;
    return results;
}

- (NSArray *)filteredTimeZonesWithCountyCode:(NSString *)countryCode {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"countryCode LIKE %@", countryCode];
    return [self.geoData filteredArrayUsingPredicate:predicate];
}

- (NSDictionary *)closesZoneInfoWithLocation:(CLLocation *)location source:(NSArray *)source {
    
    CLLocationDistance closestDistance = DBL_MAX;
    NSDictionary *closestZoneInfo = nil;
    
    for (NSDictionary *locationInfo in source) {
        
        CGFloat latitude = [locationInfo[@"lat"] floatValue];
        CGFloat longitude = [locationInfo[@"lon"] floatValue];
        
        CLLocation *zoneLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationDistance distance = [location distanceFromLocation:zoneLocation];
        if (distance < closestDistance) {
            closestDistance = distance;
            closestZoneInfo = locationInfo;
        }
    }
    return closestZoneInfo;
}

- (void) loadLocalGeoData {
    _geoData = [self geoData];
}


#pragma mark - Getters / Setters

- (NSArray*)geoData {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        geoDataStatic = [self loadOfflineDBWithPathForResource:@"TSOfflineGeocoder_geoData" ofType:@"json"];
    });
    
    return geoDataStatic;
}


#pragma mark - Public methods

- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location {
    
    NSDictionary *closeseZoneInfo = [self closesZoneInfoWithLocation:location source:self.geoData];
    
    if (closeseZoneInfo == nil) {
        return [NSTimeZone systemTimeZone];
    }
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[closeseZoneInfo objectForKey:@"timeZone"]];
    
    if (timeZone == nil) {
        NSAssert(timeZone != nil, @"TSOfflineGeocoder: Can't create timezone: %@", closeseZoneInfo);
        timeZone = [NSTimeZone systemTimeZone];
    }
    
    return timeZone;
}

- (NSTimeZone *)timeZoneWithLocation:(CLLocation *)location countryCode:(NSString *)countryCode {
    
    if (countryCode == nil) {
        return [self timeZoneWithLocation:location];
    }
    
    NSArray *filteredZones = [self filteredTimeZonesWithCountyCode:countryCode];
    NSDictionary *closeseZoneInfo = [self closesZoneInfoWithLocation:location source:filteredZones];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[closeseZoneInfo objectForKey:@"timeZone"]];
    
    if (timeZone == nil) {
        
        return [self timeZoneWithLocation:location];
    }
    
    return timeZone;
}

- (void)geocodeCoordinates:(CLLocation*)location completionHandler:(TSCompletionBlock)completionBlock {
    
    NSDictionary *resultDic = [self closesZoneInfoWithLocation:location source:self.geoData];
    if (completionBlock) {
        completionBlock(resultDic, nil);
    }
}

@end


#pragma mark - Search offline

@implementation TSGeocodeOperation (offline)

- (NSDictionary*)searchOfflineWithString:(NSString*)string {
    
    NSMutableArray *results = [NSMutableArray new];
    __block NSString *query = string;
    __block NSString *autoCompleteString = @"";
    
    // citycode begins with ...?
    NSPredicate *filter  = [NSPredicate predicateWithFormat:@"cityCode BEGINSWITH[cd] %@", query];
    NSArray *resultData = [self.geoData filteredArrayUsingPredicate:filter];
    
    // name is exactly equal?
    if ([resultData count] == 0 && !self.cancelled) {
        filter = [NSPredicate predicateWithFormat:@"name like[cd] %@", query];
        resultData = [self.geoData filteredArrayUsingPredicate:filter];
    }
    
    // name begins with ...?
    if ([resultData count] == 0 && !self.cancelled) {
        filter = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", query];
        resultData = [self.geoData filteredArrayUsingPredicate:filter];
    }
    
    // altName is containing query?
    if ([resultData count] == 0 && !self.cancelled) {
        filter = [NSPredicate predicateWithFormat:@"altNames contains[cd] %@", query];
        resultData = [self.geoData filteredArrayUsingPredicate:filter];
    }
    
    // sort on city population
    if ([resultData count] > 1 && !self.cancelled) {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"population" ascending:NO];
        resultData = [resultData sortedArrayUsingDescriptors:@[descriptor]];
    }
    
    // get the autocomplete string
    if ([resultData count] > 0 && !self.cancelled) {
        if ([[[(NSDictionary*)(resultData[0]) objectForKey:@"displayName"] lowercaseString] hasPrefix:[query lowercaseString]]) {
            NSString *displayName = [(NSDictionary*)(resultData[0]) objectForKey:@"displayName"];
            autoCompleteString = [displayName substringWithRange:NSMakeRange([query length], [displayName length] - [query length])];
        } else {
            
            // replace spaces by dashes
            NSString *displayName = [(NSDictionary*)(resultData[0]) objectForKey:@"displayName"];
            query =  [query stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            if ([[displayName lowercaseString] hasPrefix:[query lowercaseString]]) {
                autoCompleteString = [displayName substringWithRange:NSMakeRange([query length], [displayName length] - [query length])];
            }
        }
    }
    
    if ([resultData count] > 0 && !self.cancelled) {
        
        // TODO: only search in subset of results if previous search started with same letters
        // cache a subset of the list of next search
        //self.geoDataSubset = resultData;
        //self.previousSearchQuery = query;
        
        // keep only the best results (self.maxResults)
        if ([resultData count] > self.maxResults) {
            resultData = [resultData subarrayWithRange:NSMakeRange(0, self.maxResults)];
        } else {
            resultData = [resultData subarrayWithRange:NSMakeRange(0, [resultData count])];
        }
        
        for (NSDictionary *place in resultData) {
            
            [results addObject:[TSOfflineLocation objectWithDictionary:place]];
        }
        
        if (self.resultBlock) {
            
            NSDictionary *resultDic = @{
                                        kTSReturnValueAutocomplete: autoCompleteString,
                                        kTSReturnValueData: [NSArray arrayWithArray:results]
                                        };
            return resultDic;
        }
    }
    
    return nil;
}

@end


#pragma mark - Search online

@implementation TSGeocodeOperation (online)

- (void)searchOnlineWithString:(NSString*)string completeBlock:(TSCompletionBlock)completeBlock {
    
    NSMutableArray *results = [NSMutableArray new];
    __block NSString *query = string;
    __block NSString *autoCompleteString = @"";
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if ([placemarks count] > 0) {
            
            for (CLPlacemark *place in placemarks) {
                
                TSOfflineLocation *location = [TSOfflineLocation objectWithPlacemark:place];
                location.timeZone = [self timeZoneWithLocation:place.location countryCode:location.countryCode];
                [results addObject:location];
            }
            
            // get the autocomplete string
            if ([results count] > 0) {
                if ([[((TSOfflineLocation*)results[0]).displayName lowercaseString] hasPrefix:[query lowercaseString]]) {
                    NSString *displayName = ((TSOfflineLocation*)results[0]).displayName;
                    autoCompleteString = [displayName substringWithRange:NSMakeRange([query length], [displayName length] - [query length])];
                } else {
                    
                    // replace spaces by dashes
                    NSString *displayName = ((TSOfflineLocation*)results[0]).displayName;
                    query =  [query stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                    if ([[displayName lowercaseString] hasPrefix:[query lowercaseString]]) {
                        autoCompleteString = [displayName substringWithRange:NSMakeRange([query length], [displayName length] - [query length])];
                    }
                }
            }
            
            if (completeBlock) {
                NSDictionary *resultDic = @{kTSReturnValueAutocomplete: autoCompleteString,
                                            kTSReturnValueData: [NSArray arrayWithArray:results]};
                completeBlock(resultDic, nil);
            }
            
        } else {
            if (completeBlock) {
                completeBlock(nil, nil);
            }
        }
    }];
}

@end
