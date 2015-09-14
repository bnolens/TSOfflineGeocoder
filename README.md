[![Build Status](https://travis-ci.org/bnolens/TSOfflineGeocoder.svg?branch=master)](https://travis-ci.org/bnolens/TSOfflineGeocoder)

# TSOfflineGeocoder

Offline reverse geocoder for Objective-C.
Turn a string like "SF" into a location object with name, coordinates, timezone, etc. No internet connection is required.

![Demo](https://cloud.githubusercontent.com/assets/221925/9855012/20155d6a-5b0c-11e5-8f70-353f7f71debc.gif "Demo")

## Features
- Doesn't require an internet connection
- Online fallback
- Fast
- Results from all around the world
- Auto complete
- Returns an array of possible results.

## How to get started

Download TSOfflineGeocoder and try out the included iPhone example apps

### 1. Install with CocoaPods

Add the following line to your Podfile:

```ruby
pod 'TSOfflineGeocoder', :git => 'https://github.com/bnolens/TSOfflineGeocoder.git'
```

### 2. Import

Import the offline geocoder in your project

```objc
#import "TSOfflineGeocoder.h"
```

### 3. Use

Instantiate the geocoder using:

```objc
TSOfflineGeocoder  *offlineGeocoder = [TSOfflineGeocoder new];
```

Search for locations using a string:

```objc
[offlineGeocoder geocodeAddressString:@"San Francisco" completionHandler:^(NSDictionary *results, NSError *error) {
  if (results) {
      TSOfflineLocation *firstLocation = (TSOfflineLocation*)((NSArray*)[results objectForKey:kTSReturnValueData])[0];
      NSLog(@"%@", firstLocation.displayName);
  }
}];
```

## License

License: TSOfflineGeocoder

Copyright 2015 Benoit Nolens - http://truestory.io

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


License: Places database (TSOfflineGeocoder_geoData.json)

 Source: http://www.geonames.org
 Updated by: truestory.io
 License: http://creativecommons.org/licenses/by/3.0/
