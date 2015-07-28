//
//  NSString+Additions.m
//  Pods
//
//  Created by Benoit Nolens on 7/22/15.
//
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL) isBlank {
    
    if([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString*) ASCIIEncode {
    
    NSData *decode = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[NSString alloc] initWithData:decode encoding:NSASCIIStringEncoding];
}

@end
