#
# Be sure to run `pod lib lint Brilliant.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Brilliant"
  s.version          = "0.3"
  s.summary          = "A library for in-app NPS Surveys"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                         Brilliant is a library for in-app nps (net promoter score) surveys
                       DESC

  s.homepage         = "https://github.com/tomboates/BrilliantSDK"
  s.screenshots     = "http://www.brilliant-llc.com/nps.png", "http://www.brilliant-llc.com/comments.png", "http://www.brilliant-llc.com/rating.png"
  s.license          = 'MIT'
  s.author           = { "Tom Boates" => "tom.boates@me.com" }
  s.source           = { :git => "https://github.com/tomboates/BrilliantSDK.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/brilliantnps'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundle = { 'Brilliant' => ['Assets/*.png', 'Assets/*.xib'] }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 3'
  s.dependency 'ReachabilitySwift', '3.0'
end
