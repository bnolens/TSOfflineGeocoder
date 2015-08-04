Pod::Spec.new do |s|
  s.name             = "TSOfflineGeocoder"
  s.version          = "0.1.4"
  s.summary          = "Offline reverse geocoder for Objective-c"
  s.description      = <<-DESC
* Offline with online fallback
* Fast
* Worldwide locations
                       DESC
  s.homepage         = "https://github.com/bnolens/TSOfflineGeocoder"
  s.license          = "MIT"
  s.author           = { "Benoit Nolens" => "benoit@truestory.io" }
  s.source           = { :git => "https://github.com/bnolens/TSOfflineGeocoder.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = '10.7'

  s.requires_arc = true

  s.source_files = "Pod/Classes/lib/"
  s.resources = "Pod/Resources/TSOfflineGeocoder_geoData.json"
end
