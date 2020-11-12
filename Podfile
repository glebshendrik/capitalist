# Uncomment the next line to define a global platform for your project
platform :ios, '11.2'

target 'Capitalist' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Three Baskets
  pod 'Swinject', '2.6.2'
  pod 'SwinjectStoryboard', '2.2'
  pod 'SwinjectAutoregistration', '2.6.0'
  pod 'Locksmith', '~> 4.0'
  pod 'PromiseKit', '~> 6.5'
  pod 'PromiseKit/Alamofire', '~> 6.5'
  pod 'IQKeyboardManager'
  pod 'AlamofireImage'
  pod 'SVProgressHUD', '~> 2.2'
  pod 'SwiftDate', '~> 6.1'
  pod 'SwifterSwift', '~> 5.1'
  pod 'CWStatusBarNotification', '~> 2.3'
  pod 'SideMenu', git: 'https://github.com/jonkykong/SideMenu', branch: 'master'
  pod 'StaticTableViewController'
  pod 'SwiftMessages'
  pod 'SkyFloatingLabelTextField'
  pod 'CircleProgressView', '~> 1.0'
  pod 'BEMCheckBox'
  pod 'AlignedCollectionViewFlowLayout'
#  pod 'ALTextInputBar' #, git: 'https://github.com/bclymer/ALTextInputBar', branch: 'master'
  pod 'Charts'
  pod 'RandomColorSwift', git: 'https://github.com/onevcat/RandomColorSwift', branch: 'master'
  pod 'MSPeekCollectionViewDelegateImplementation', '~> 2.0'
  pod 'CSV.swift'
  pod 'RecurrencePicker', git: 'https://github.com/petalvlad/RecurrencePicker', branch: 'master' 
#  pod 'SaltEdge-iOS-Swift', git: 'https://github.com/petalvlad/saltedge-ios-swift', branch: 'v3.3.1'
  pod 'SaltEdge-iOS-Swift', '3.3.9'
  pod 'SVGKit', '~> 2.1'
  pod 'SDWebImageSVGCoder', '~> 0.3'
  pod 'SnapKit', '~> 4.2.0'
  pod 'AttributedTextView'
  pod "ESPullToRefresh"
  pod 'BetterSegmentedControl', '~> 1.3'
  pod 'EasyTipView', '~> 2.0.4'
  pod 'BiometricAuthentication'
  pod 'ApphudSDK'
  pod 'InfiniteLayout'
  pod 'SwiftyGif'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'FBSDKCoreKit/Swift'
  pod 'myTrackerSDK'
  pod "Haptica"
  pod 'SwipeCellKit'
  pod 'BadgeHub'
  pod 'Macaw', git: 'https://github.com/petalvlad/Macaw', branch: 'master'
  pod 'SwiftyBeaver'
  pod 'Adjust', '~> 4.22.1'
  pod 'lottie-ios'
  pod 'UPCarouselFlowLayout'
  pod 'PopupDialog', '~> 1.1'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
        config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
#        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
      end
    end
end
