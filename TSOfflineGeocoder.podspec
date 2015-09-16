Pod::Spec.new do |s|
  s.name             = "TSOfflineGeocoder"
  s.version          = "0.1.5"
  s.summary          = "Offline reverse geocoder for Objective-c"
  s.description      = <<-DESC
  * Finds locations using strings or coordinates
  * No internet required
  * Online fallback
  * Results from all around the world
  * Fast
  * Auto complete
  * Returns an array of possible results.
                       DESC
  s.homepage         = "https://github.com/bnolens/TSOfflineGeocoder"
  s.license          = { :type => "MIT", :file => "LICENSE.txt" }
  s.author           = { "Benoit Nolens" => "benoit@truestory.io" }
  s.source           = { :git => "https://github.com/bnolens/TSOfflineGeocoder.git", :tag => "v#{s.version}" }

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = '10.7'

  s.requires_arc = true

  s.source_files = "Pod/Classes/lib/"
  s.resources = "Pod/Resources/TSOfflineGeocoder_geoData.json"
end
