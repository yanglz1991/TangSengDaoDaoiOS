#
# Be sure to run `pod lib lint QCCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QCCore'
  s.version          = '0.1.0'
  s.summary          = 'A short description of QCCore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tangtaoit/QCCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tangtaoit' => 'tt@wukong.ai' }
  s.source           = { :git => 'https://github.com/tangtaoit/QCCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.platform     = :ios, '12.0'
  
  s.resource_bundles = {
    'QCCore_images' => ['QCCore/Assets/Images.xcassets'],
    'QCCore_resources' => ['QCCore/Assets/DB','QCCore/Assets/emoji','QCCore/Assets/Other']
  }
 
 s.resources = ['QCCore/Assets/Lang']

  
 
  s.private_header_files = 'QCCore/Classes/Vendor/**/*'
  s.source_files = 'QCCore/Classes/**/*'
#  s.preserve_paths = 'ios/arm/*.{a}'
#   s.vendored_frameworks  = 'ios/QCIM.framework'
  
   
  # s.ios.resource   = 'ios/QCIM.framework/Versions/A/Resources/QCIM.bundle'
  
#  s.static_framework = true
#  s.dependency 'QCIM', '~> 0.1.19'

#  s.pod_target_xcconfig = {
#    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#     'DEFINES_MODULE' => 'YES',
#     'ENABLE_BITCODE' => 'YES',
#     'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
#  }
#   s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
#  s.vendored_libraries = 'QCCore/QCIM-Framework/ios/*.{a}'
#  s.resource  = 'QCCore/QCIM-Framework/ios/QCIM.framework/Versions/A/Resources/QCIM.bundle'
  s.vendored_frameworks = 'QCCore/Bugly.framework'
#  s.libraries = 'opencore-amrnb', 'opencore-amrwb','vo-amrwbenc', 'sqlite3', 'stdc++','xml2'
  s.libraries = 'c++','stdc++'
#  s.dependency 'FLEX'
  s.dependency 'QCIM'
  s.dependency 'CocoaLumberjack','~> 3.0'
  s.dependency 'PromiseKit/CorePromise', '~> 6.0'
  s.dependency 'AFNetworking', '~> 4.0'
  s.dependency 'Toast','~> 4.0'
  s.dependency 'MBProgressHUD', '~> 1.1.0'
  s.dependency 'DGActivityIndicatorView', '~> 2.1.1'
  s.dependency 'M80AttributedLabel', '~> 1.9.9'
  s.dependency 'YBImageBrowser/NOSD','~> 3.0'
  s.dependency 'YYImage/WebP','~> 1.0.4'
  s.dependency 'TZImagePickerController', '~>3.6.4'
#  s.dependency 'MenuItemKit', '~> 4.0.0'
  s.dependency 'LBXScan/LBXNative', '~> 2.5'
  s.dependency 'LBXScan/LBXZXing', '~> 2.5'
  s.dependency 'LBXScan/UI', '~> 2.5'
  s.dependency 'MJRefresh','~> 3.0'
#  s.dependency 'QCJavaScriptBridge', '~> 1.0.0'
  s.dependency 'CocoaAsyncSocket', '~> 7.6.5'
  s.dependency 'TOCropViewController', '~> 2.5.3'
  s.dependency 'SDWebImage','~> 5.9.1'
  s.dependency 'SDWebImageWebPCoder','~> 0.6.1'
#  s.dependency 'FMDB', '2.5'
  s.dependency 'FMDB/SQLCipher', '~>2.7.5'
  s.dependency 'lottie-ios', '~> 2.5.3'
  s.dependency 'SDWebImageLottieCoder','~> 0.1.0'
  s.dependency 'GZIP','~> 1.3.0'
  s.dependency 'ZLPhotoBrowser', '~> 4.5'
  s.dependency 'ZLImageEditor', '~> 1.1.1'
  s.dependency 'ActionSheetPicker-3.0'
#  s.dependency 'VIMediaCache', '~> 0.4'
  s.dependency 'AsyncDisplayKit', '~> 1.0'
  s.dependency 'FPSCounter', '~> 4.1'
  s.dependency 'librlottie', '~> 0.1'
  
#  s.dependency 'SVGKit'
  
  
  # s.resource_bundles = {
  #   'QCCore' => ['QCCore/Assets/*.png']
  # }
 
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
#  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '/Users/tt/work/projects/mos/QCIMDemo/Modules/QCCore/ios/arm',"OTHER_LDFLAGS" => "-ObjC" }
  s.frameworks = 'UIKit', 'MapKit', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  
  
end
