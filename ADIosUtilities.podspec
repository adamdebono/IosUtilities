#
#  Be sure to run `pod s lint ADIosUtilities.pods' to ensure this is a
#  valid s and to remove all comments including this before submitting the s.
#
#  To learn more about Pods attributes see https://docs.cocoapods.org/sification.html
#  To see working Podss in the CocoaPods repo see https://github.com/CocoaPods/ss/
#

Pod::Spec.new do |s|
  s.name         = "ADIosUtilities"
  s.version      = "0.0.1"
  s.summary      = "A collection of useful utilities"

  s.homepage     = "https://github.com/adamdebono/IosUtilities"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Adam Debono" => "me@adamdebono.com" }

  s.ios.deployment_target  = "10.0"
  s.tvos.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/adamdebono/IosUtilities.git", :tag => "#{s.version}" }
  s.source_files = "Source/**/*.swift"
end
