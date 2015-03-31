Pod::Spec.new do |s|
  s.name         = "UriBeacon"
  s.version      = "0.0.4"
  s.summary      = "Easily discover and interact with UriBeacons"
  s.description  = "Connect your iOS application to the Physical Web by allowing users to discover and interact with bluetooth UriBeacons"
  s.homepage     = "http://bluebite.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Tanner Nelson" => "me@tanner.xyz" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/tannernelson/uribeacon.git", :tag => "0.0.4" }
  s.source_files  = "Classes"
end
