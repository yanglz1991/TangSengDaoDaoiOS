# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'
workspace 'TangSengDaoDaoiOS.xcworkspace'

post_install do |installer|
    # 填写你自己的开发者团队的team id
    dev_team = "F68A4Y2SZ5"
    project = installer.aggregate_targets[0].user_project
    project.targets.each do |target|
        target.build_configurations.each do |config|
            if dev_team.empty? and !config.build_settings['DEVELOPMENT_TEAM'].nil?
                dev_team = config.build_settings['DEVELOPMENT_TEAM']
            end
        end
    end
    
    # Fix bundle targets' 'Signing Certificate' to 'Sign to Run Locally'
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
              config.build_settings['DEVELOPMENT_TEAM'] = dev_team
            end
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
            config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        end
        
    end

    # ------------------------------------------------------------------
    # 为 Apple 要求但未自带 PrivacyInfo.xcprivacy 的第三方 Pod 注入隐私清单
    # 解决 App Store 审核错误 ITMS-91061: Missing privacy manifest
    # 模板位于 ./privacy_manifests/PrivacyInfo.xcprivacy
    # ------------------------------------------------------------------
    require 'fileutils'

    privacy_manifest_pods = %w[AFNetworking FMDB MBProgressHUD SDWebImage Starscream Toast]
    privacy_manifest_template = File.expand_path('privacy_manifests/PrivacyInfo.xcprivacy', __dir__)

    if File.exist?(privacy_manifest_template)
        # 按 pod 名遍历（而不是按 target 名），因为某些 pod（如 Starscream）会被 CocoaPods
        # 拆成多个 target（Starscream-framework / Starscream-library），target.name != pod 名。
        privacy_manifest_pods.each do |pod_name|
            pod_dir = File.join(installer.sandbox.root, pod_name)
            unless File.directory?(pod_dir)
                Pod::UI.warn "  - 跳过 #{pod_name}: 未找到 Pod 目录 #{pod_dir}"
                next
            end

            dst_manifest = File.join(pod_dir, 'PrivacyInfo.xcprivacy')
            FileUtils.cp(privacy_manifest_template, dst_manifest)

            # 选出该 pod 名下所有 native target（含 -framework / -library 等变体）
            matching_targets = installer.pods_project.targets.select do |t|
                t.name == pod_name || t.name.start_with?("#{pod_name}-")
            end

            if matching_targets.empty?
                Pod::UI.warn "  - 未找到 #{pod_name} 对应的 native target"
                next
            end

            group = installer.pods_project.main_group.find_subpath(pod_name, true)
            group.set_source_tree('<group>') if group.source_tree.to_s.empty?

            # 复用已存在的 file_ref，避免重复添加到 group
            existing_ref = group.files.find do |f|
                f.path && f.path.to_s.end_with?('PrivacyInfo.xcprivacy')
            end
            file_ref = existing_ref || group.new_reference(dst_manifest)

            matching_targets.each do |target|
                next unless target.respond_to?(:resources_build_phase) && target.resources_build_phase

                already_added = target.resources_build_phase.files_references.any? do |ref|
                    ref && ref.path && ref.path.to_s.end_with?('PrivacyInfo.xcprivacy')
                end
                next if already_added

                target.resources_build_phase.add_file_reference(file_ref, true)
                Pod::UI.puts "  - 已为 target #{target.name} 注入 PrivacyInfo.xcprivacy".green
            end
        end

        # 保存 Pods.xcodeproj 修改
        installer.pods_project.save
    else
        Pod::UI.warn "未找到 privacy manifest 模板: #{privacy_manifest_template}"
    end
end


abstract_target 'TangSengDaoDaoiOSBase' do
  
#  pod 'lottie-ios', '~> 2.5.3'
  pod 'Socket.IO-Client-Swift'
  pod 'SSZipArchive', '~> 2.2.3'
  pod 'SocketRocket'
  pod 'Aspects'
  pod 'ReactiveObjC'

  target 'TangSengDaoDaoiOS' do
    project 'TangSengDaoDaoiOS.xcodeproj'
    
  use_frameworks!
  pod 'YBImageBrowser/NOSD', :git=>'https://github.com/tangtaoit/YBImageBrowser.git'
  pod 'YYImage/WebP', :git => 'https://github.com/tangtaoit/YYImage.git'
  pod 'AsyncDisplayKit', :git => 'https://github.com/tangtaoit/AsyncDisplayKit.git'
  pod 'librlottie', :git => 'https://github.com/tangtaoit/librlottie.git'
  
  pod 'WuKongIMSDK',  :path => './Modules/WuKongIMiOSSDK'   ## WuKongBase 基础工具包  源码地址 https://github.com/WuKongIM/WuKongIMiOSSDK
#  pod 'WuKongIMSDK',  :path => '../../../wukongIM/iOS/WuKongIMiOSSDK'
#  pod  'WuKongIMSDK', '~> 1.0.2' ## 源码地址 https://github.com/WuKongIM/WuKongIMiOSSDK
  pod 'WuKongBase',  :path => './Modules/WuKongBase'   ## WuKongBase 基础工具包
  pod 'WuKongLogin', :path => './Modules/WuKongLogin'  ##  登录模块
  pod 'WuKongContacts', :path => './Modules/WuKongContacts'  ## 联系人模块
  pod 'WuKongDataSource', :path => './Modules/WuKongDataSource'  ## 数据源
  pod 'WuKongFile', :path => './Modules/WuKongFile'  ## 文件管理
  pod 'WuKongGroupManager', :path => './Modules/WuKongGroupManager'  ## 群管理
  pod 'WuKongSmallVideo', :path => './Modules/WuKongSmallVideo'  ## 小视频
  end
  
end


