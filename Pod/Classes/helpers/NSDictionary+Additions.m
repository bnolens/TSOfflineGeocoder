//
//  NSDictionary+Additions.m
//  Pods
//
//  Created by Benoit Nolens on 7/22/15.
//
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (BOOL) hasKey:(NSString*)key {
    
    return ([self objectForKey:key] != nil && ![[self objectForKey:key] isEqual:[NSNull null]]);
}

@end
