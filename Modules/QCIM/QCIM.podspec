#
# Be sure to run `pod lib lint QCIM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QCIM'
  s.version          = '1.1.0'
  s.summary          = 'QX IM是一款简单，高效，支持完全私有化的即时通讯.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
QX IM是一款简单，高效，支持完全私有化的即时通讯，提供群聊，点对点通讯解决方案.
                       DESC

  s.homepage         = 'https://github.com/qx-team/QCIM'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qx-team' => 'tt@tgo.ai' }
  s.source           = { :git => "https://github.com/qx-team/QCIM.git" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.platform     = :ios, '11.0'
  s.requires_arc = true
  
  s.ios.deployment_target = '11.0'
  
  s.vendored_libraries = 'QCIM/Classes/private/arm/lib/*.a'
  
  s.preserve_paths = 'QCIM/Classes/private/arm/lib/*.a'
  s.libraries = 'opencore-amrnb', 'opencore-amrwb','vo-amrwbenc'

  s.source_files = 'QCIM/Classes/**/*'
  s.public_header_files =  'QCIM/Classes/**/*.h'
  s.private_header_files = 'QCIM/Classes/private/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'Security'
#  s.xcconfig = {
#      'ENABLE_BITCODE' => 'NO',
#      "OTHER_LDFLAGS" => "-ObjC"
#  }
  
  s.resource_bundles = {
    'QCIM' => ['QCIM/Assets/*.png','QCIM/Assets/Migrations/*']
  }
  
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'DEFINES_MODULE' => 'YES'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.dependency 'CocoaAsyncSocket', '~> 7.6.5'
  s.dependency 'FMDB/SQLCipher', '~>2.7.5'
  s.dependency '25519', '~>2.0.2'
end
