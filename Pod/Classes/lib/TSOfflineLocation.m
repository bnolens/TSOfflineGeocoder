//
//  TSOfflineLocation.m
//  Memento
//
//  Created by Benoit Nolens on 12/06/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

#import "TSOfflineLocation.h"

@implementation TSOfflineLocation

@synthesize coordinates, name, displayName, altNames, population, countryCode, altCountryCode, timeZone, isCurrentLocation;

+ (instancetype) objectWithDictionary:(NSDictionary *)dic{
    
    TSOfflineLocation *location = [[TSOfflineLocation alloc] init];
    
    if(([dic objectForKey:@"lat"] != nil && ![[dic objectForKey:@"lat"] isEqual:[NSNull null]]) && ([dic objectForKey:@"lon"] != nil && ![[dic objectForKey:@"lon"] isEqual:[NSNull null]])){
        location.coordinates = CLLocationCoordinate2DMake([[dic objectForKey:@"lat"] doubleValue], [[dic objectForKey:@"lon"] doubleValue]);
    }else{
        location.coordinates = CLLocationCoordinate2DMake(0, 0);
    }
    
    if([dic objectForKey:@"name"] != nil && ![[dic objectForKey:@"name"] isEqual:[NSNull null]]){
        location.name = [dic objectForKey:@"name"];
    }else{
        location.name = @"";
    }
    
    if([dic objectForKey:@"displayName"] != nil && ![[dic objectForKey:@"displayName"] isEqual:[NSNull null]]){
        location.displayName = [dic objectForKey:@"displayName"];
    }else{
        location.displayName = @"";
    }
    
    if([dic objectForKey:@"altNames"] != nil && ![[dic objectForKey:@"altNames"] isEqual:[NSNull null]]){
        location.altNames = [dic objectForKey:@"altNames"];
    }else{
        location.altNames = @"";
    }
    
    if([dic objectForKey:@"population"] != nil && ![[dic objectForKey:@"population"] isEqual:[NSNull null]]){
        location.population = [dic objectForKey:@"population"];
    }else{
        location.population = 0;
    }
    
    if([dic objectForKey:@"countryCode"] != nil && ![[dic objectForKey:@"countryCode"] isEqual:[NSNull null]]){
        location.countryCode = [dic objectForKey:@"countryCode"];
    }else{
        location.countryCode = @"";
    }
    
    if([dic objectForKey:@"altCountryCode"] != nil && ![[dic objectForKey:@"altCountryCode"] isEqual:[NSNull null]]){
        location.altCountryCode = [dic objectForKey:@"altCountryCode"];
    }else{
        location.altCountryCode = @"";
    }
    
    if([dic objectForKey:@"timeZone"] != nil && ![[dic objectForKey:@"timeZone"] isEqual:[NSNull null]]){
        location.timeZone = [NSTimeZone timeZoneWithName:[dic objectForKey:@"timeZone"]];
        if (location.timeZone == nil) {
            location.timeZone = [NSTimeZone timeZoneWithAbbreviation:location.countryCode];
        }
    }else{
        location.timeZone = nil;
    }
    
    
    return location;
}

+ (instancetype) objectWithPlacemark:(CLPlacemark *)placemark{

    TSOfflineLocation *location = [[TSOfflineLocation alloc] init];
    
    if (CLLocationCoordinate2DIsValid(placemark.location.coordinate)) {
        location.coordinates = placemark.location.coordinate;
    }
    
    if(placemark.locality != nil){
        location.name = placemark.locality;
        location.displayName = placemark.locality;
        location.altNames = placemark.locality;
    }else{
        location.name = @"";
        location.displayName = @"";
        location.altNames = @"";
    }
    
    location.population = 0;
    location.countryCode = placemark.ISOcountryCode;
    location.altCountryCode = @"";
    
    return location;
}

#pragma mark - NSObject

- (void)encodeWithCoder:(NSCoder *)encoder {

    NSNumber *lat = [NSNumber numberWithDouble:self.coordinates.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:self.coordinates.longitude];
    NSDictionary *coordinatesDic = @{@"lat":lat,@"lon":lon};
    
    [encoder encodeObject:coordinatesDic forKey:@"coordinates"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.displayName forKey:@"displayName"];
    [encoder encodeObject:self.altNames forKey:@"altNames"];
    [encoder encodeObject:self.population forKey:@"population"];
    [encoder encodeObject:self.countryCode forKey:@"countryCode"];
    [encoder encodeObject:self.altCountryCode forKey:@"altCountryCode"];
    [encoder encodeObject:self.timeZone forKey:@"timeZone"];
    [encoder encodeObject:@(self.isCurrentLocation) forKey:@"isCurrentLocation"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if(self = [super init]) {
        NSDictionary *coordinatesDic = [decoder decodeObjectForKey:@"coordinates"];
        if (coordinatesDic) {
            self.coordinates = CLLocationCoordinate2DMake([coordinatesDic[@"lat"] doubleValue], [coordinatesDic[@"lon"] doubleValue]);
        }
        self.name = [decoder decodeObjectForKey:@"name"];
        self.displayName = [decoder decodeObjectForKey:@"displayName"];
        self.altNames = [decoder decodeObjectForKey:@"altNames"];
        self.population = [decoder decodeObjectForKey:@"population"];
        self.countryCode = [decoder decodeObjectForKey:@"countryCode"];
        self.altCountryCode = [decoder decodeObjectForKey:@"altCountryCode"];
        self.timeZone = [decoder decodeObjectForKey:@"timeZone"];
        self.isCurrentLocation = [[decoder decodeObjectForKey:@"isCurrentLocation"] boolValue];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    
    TSOfflineLocation *location = [TSOfflineLocation new];
    location.coordinates = self.coordinates;
    location.name = self.name;
    location.displayName = self.displayName;
    location.altNames = self.altNames;
    location.population = self.population;
    location.countryCode = self.countryCode;
    location.altCountryCode = self.altCountryCode;
    location.timeZone = self.timeZone;
    location.isCurrentLocation = self.isCurrentLocation;
    return location;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"- TSOfflineLocation - \nname: %@, \ncoordinates: (%f, %f), \ntimezone: %@", self.displayName, self.coordinates.latitude, self.coordinates.longitude, timeZone.description];
}

- (BOOL) isEqualToLocation:(TSOfflineLocation*)location {
    
    if (!location) {
        return NO;
    }
    
    BOOL haveEqualCoordinates = (self.coordinates.latitude == location.coordinates.latitude && self.coordinates.longitude == location.coordinates.longitude);
    BOOL haveEqualName = (!self.name && !location.name) || ([self.name isEqualToString:location.name]);
    BOOL haveEqualDisplayName = (!self.displayName && !location.displayName) || ([self.displayName isEqualToString:location.displayName]);
    BOOL haveEqualAltNames = (!self.altNames && !location.altNames) || ([self.altNames isEqualToString:location.altNames]);
    BOOL haveEqualPopulation = (!self.population && !location.population) || ([self.population isEqualToNumber:location.population]);
    BOOL haveEqualCountryCode = (!self.countryCode && !location.countryCode) || ([self.countryCode isEqualToString:location.countryCode]);
    BOOL haveEqualAltCountryCode = (!self.altCountryCode && !location.altCountryCode) || ([self.altCountryCode isEqualToString:location.altCountryCode]);
    BOOL haveEqualTimeZone = (!self.timeZone && !location.timeZone) || ([self.timeZone isEqualToTimeZone:location.timeZone]);
    BOOL haveEqualIsCurrentLocation = (self.isCurrentLocation == location.isCurrentLocation);
    
    return haveEqualCoordinates && haveEqualName && haveEqualDisplayName && haveEqualAltNames && haveEqualPopulation && haveEqualCountryCode && haveEqualAltCountryCode && haveEqualTimeZone && haveEqualIsCurrentLocation;
}

@end
