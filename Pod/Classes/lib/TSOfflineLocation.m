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

#pragma mark - Helpers

-(instancetype)copyWithZone:(NSZone *)zone {
    
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

@end
