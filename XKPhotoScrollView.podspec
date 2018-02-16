#
# Be sure to run `pod lib lint XKPhotoScrollView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XKPhotoScrollView"
  s.version          = "0.1.7"
  s.summary          = "A photo viewer to mimic the Photos app full-screen view."
  s.description      = <<-DESC
                       A UIView sublcass that implements a swipeable, zoomable multi-photo viewer with lots of configuration
                       and event hooks.
                       DESC
  s.homepage         = "https://github.com/karlvr/XKPhotoScrollView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Karl von Randow" => "karl@cactuslab.com" }
  s.source           = { :git => "https://github.com/karlvr/XKPhotoScrollView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/avon'

  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
