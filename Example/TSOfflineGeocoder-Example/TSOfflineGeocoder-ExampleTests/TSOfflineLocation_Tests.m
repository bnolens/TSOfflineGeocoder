//
//  TSOfflineLocation_Tests.m
//  TSOfflineGeocoder-Example
//
//  Created by Benoit Nolens on 8/4/15.
//  Copyright (c) 2015 True Story. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <TSOfflineGeocoder/TSOfflineGeocoder.h>

@interface TSOfflineLocation_Tests : XCTestCase

@property (strong, nonatomic) TSOfflineGeocoder *offlineGeocoder;

@end

@implementation TSOfflineLocation_Tests

- (void)setUp {
    [super setUp];
    
    self.offlineGeocoder = [TSOfflineGeocoder new];
    self.offlineGeocoder.onlineFallbackEnabled = NO;
}

- (void)tearDown {
    [super tearDown];
}

- (void) testCopyObject {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"2 location objects should be equal after copy"];
    
    // Find location data for query
    [self.offlineGeocoder geocodeAddressString:@"London" completionHandler:^(NSDictionary *results, NSError *error) {
        if (results) {
            
            TSOfflineLocation *location = (TSOfflineLocation*)((NSArray*)[results objectForKey:kTSReturnValueData])[0];
            TSOfflineLocation *copiedLocation = [location copy];
            
            XCTAssertTrue([location isEqualToLocation:copiedLocation]);
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

- (void)testEncodeDecodeObject {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"2 location objects should be equal after encode/decode"];
    
    // Find location data for query
    [self.offlineGeocoder geocodeAddressString:@"London" completionHandler:^(NSDictionary *results, NSError *error) {
        if (results) {
            
            TSOfflineLocation *location = (TSOfflineLocation*)((NSArray*)[results objectForKey:kTSReturnValueData])[0];
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:location];
            TSOfflineLocation *decodedObject = (TSOfflineLocation*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            
            XCTAssertTrue([location isEqualToLocation:decodedObject]);
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

@end
