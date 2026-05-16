#
# Be sure to run `pod lib lint QCAuth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QCAuth'
  s.version          = '0.1.0'
  s.summary          = 'A short description of QCAuth.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qx-team/QCAuth'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qx-team' => 'tt@qx.ai' }
  s.source           = { :git => 'https://github.com/qx-team/QCAuth.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'QCAuth/Classes/**/*'
  
  s.resource_bundles = {
    'QCAuth_images' => ['QCAuth/Assets/Images.xcassets']
  }
  s.private_header_files = 'QCAuth/Classes/Vendor/*.h'
  
  s.resources = ['QCAuth/Assets/Lang']
  
  # s.resource_bundles = {
  #   'QCAuth' => ['QCAuth/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'QCCore'
  s.dependency 'PromiseKit/CorePromise', '~> 6.0'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage','~> 5.9.1'
end
