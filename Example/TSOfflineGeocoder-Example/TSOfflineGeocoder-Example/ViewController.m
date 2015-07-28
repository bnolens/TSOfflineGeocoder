//
//  ViewController.m
//  TSOfflineGeocoder
//
//  Created by Benoit Nolens on 03/12/14.
//  Copyright (c) 2014 True Story. All rights reserved.
//

#import "ViewController.h"
#import <TSOfflineGeocoder/TSOfflineGeocoder.h>

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *inputField;
@property (strong, nonatomic) IBOutlet UITextView *console;
@property (strong, nonatomic) TSOfflineGeocoder *offlineGeocoder;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offlineGeocoder = [TSOfflineGeocoder new];
    self.offlineGeocoder.onlineFallbackEnabled = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.inputView becomeFirstResponder];
}

- (void) geocodeWithString:(NSString*)string {
    
    // Find location data for query
    [self.offlineGeocoder geocodeAddressString:string completionHandler:^(NSDictionary *results, NSError *error) {
        if (results) {
            
            TSOfflineLocation *firstLocation = (TSOfflineLocation*)((NSArray*)[results objectForKey:kTSReturnValueData])[0];
            NSString *autoCompleteString = [results objectForKey:kTSReturnValueAutocomplete];
            
            self.console.text = [NSString stringWithFormat:@"Auto complete string: %@ \n\nLocation name: %@ \ncoordinates: (%f - %f) \ntimeZone: %@", autoCompleteString, firstLocation.displayName, firstLocation.coordinates.latitude, firstLocation.coordinates.longitude, firstLocation.timeZone.description];
        }
    }];
}

#pragma mark - UITextFieldDelgate

- (void) textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length > 0) {
        [self geocodeWithString:textView.text];
    } else {
        self.console.text = @"";
    }
}

@end
