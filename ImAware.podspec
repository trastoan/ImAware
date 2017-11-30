#
# Be sure to run `pod lib lint ImAware.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ImAware'
  s.version          = '0.4.6'
  s.summary          = 'A framework that helps the creation of context aware applications, it makes easier to get hardware data and setup location fences.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A framework that helps the creation of context aware applications, it makes easier to get hardware data and setup location fences.
Get Snapshot data from:
- Battery
- Power Mode
- Headphones
- Brightness
- Disk Usage
                       DESC

  s.homepage         = 'https://github.com/trastoan/ImAware'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'trastoan' => 'yurisaboiaf@gmail.com' }
  s.source           = { :git => 'https://github.com/trastoan/ImAware.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ImAware/Source/**/*'
  
  # s.resource_bundles = {
  #   'ImAware' => ['ImAware/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Source/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
