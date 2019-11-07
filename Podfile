# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Three Baskets' do
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
  pod 'SwifterSwift', '~> 4.6'
  pod 'CWStatusBarNotification', '~> 2.3'
  pod 'SideMenu', '6.3.1'
  pod 'StaticTableViewController'
  pod 'SwiftMessages'
  pod 'SkyFloatingLabelTextField'
  pod 'CircleProgressView', '~> 1.0'
  pod 'BEMCheckBox'
  pod 'AlignedCollectionViewFlowLayout'
  pod 'ALTextInputBar', git: 'https://github.com/bclymer/ALTextInputBar', branch: 'master'
  pod 'Charts'
  pod 'RandomColorSwift', git: 'https://github.com/onevcat/RandomColorSwift', branch: 'master'
  pod 'MSPeekCollectionViewDelegateImplementation', '~> 2.0'
  pod 'CSV.swift'
  pod 'RecurrencePicker', git: 'https://github.com/petalvlad/RecurrencePicker', branch: 'master' 
  pod 'SaltEdge-iOS-Swift', git: 'https://github.com/petalvlad/saltedge-ios-swift', branch: 'master'
  pod 'SVGKit', '~> 2.1'
  pod 'SDWebImageSVGCoder', '~> 0.3'
  pod 'SnapKit', '~> 4.2.0'
  pod 'AttributedTextView'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
