//
//  TSOfflineGeocoder_Tests.m
//  TSOfflineGeocoder-Example
//
//  Created by Benoit Nolens on 8/4/15.
//  Copyright (c) 2015 True Story. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <TSOfflineGeocoder/TSOfflineGeocoder.h>

@interface TSOfflineGeocoder_Tests : XCTestCase

@property (strong, nonatomic) TSOfflineGeocoder *offlineGeocoder;

@end

@implementation TSOfflineGeocoder_Tests

- (void)setUp {
    [super setUp];
    
    self.offlineGeocoder = [TSOfflineGeocoder new];
    self.offlineGeocoder.onlineFallbackEnabled = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReverseGeocodeAddressOffline {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"A location object should be found"];
    
    self.offlineGeocoder.onlineFallbackEnabled = NO;
    
    // Find location data for query
    [self.offlineGeocoder geocodeAddressString:@"New York" completionHandler:^(NSDictionary *results, NSError *error) {
        if (results) {
            
            TSOfflineLocation *location = (TSOfflineLocation*)((NSArray*)[results objectForKey:kTSReturnValueData])[0];
            
            XCTAssertTrue(location && [location.name isEqualToString:@"New York City"]);
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
