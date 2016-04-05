# Uncomment this line to define a global platform for your project
platform :ios, '8.1'
# Uncomment this line if you're using Swift
use_frameworks!

def keyboardPods
    pod 'ReactiveCocoa', '4.0.4-alpha-4'
    pod 'KeyboardFramework', :path => '../Keyboard'
end

target 'GetGems' do
	pod 'FXForms', '1.1'
    pod 'libPhoneNumber-iOS', '~> 0.7'
    pod 'Lambda-Alert'
    pod 'ZXingObjC', '3.1.0'
    pod 'PTEHorizontalTableView'
    pod 'SDWebImage', '3.7.3'
    pod 'iOS-blur'
    pod 'CustomIOSAlertView', '0.9.3'
    pod 'VBFPopFlatButton'
    pod 'SSKeychain'
    pod 'PBJVideoPlayer'

    pod 'SwaggerClient', :path => '../gems-app-ios/GemsCore/GemsNetworking/ThirdParty/swagger/'
    pod 'GemsNetworking', :path => '../gems-app-ios/GemsCore/GemsNetworking'
    pod 'GemsCurrencyManager', :path => '../gems-app-ios/GemsCore/GemsCurrencyManager/'
    pod 'BreadWalletCore', :path => '../BRCore'
    pod 'GemsCore/Full', :path => '../gems-app-ios/GemsCore'
    pod 'GemsUI', :path => '../gems-app-ios/GemsUI'

    keyboardPods
end

target 'keyboard' do
    keyboardPods
    #pod 'GemsCore/AppExtension', :path => '../gems-app-ios/GemsCore'
    pod 'GemsNetworking', :path => '../gems-app-ios/GemsCore/GemsNetworking'
    pod 'Mixpanel/AppExtension', '2.9.0'
end

target 'Share' do

end

target 'watchkitapp' do

end

target 'watchkitapp Extension' do

end

post_install do |installer|
	def remove_xcode_6_module_import_for_objcPlusPlus
		workDir = Dir.pwd
        #SSKeyChain
        file_names = ["#{workDir}/Pods/SSKeychain/SSKeychain/SSKeychainQuery.h","#{workDir}/Pods/SSKeychain/SSKeychain/SSKeychain.h"]
        file_names.each do |file_name|
            File.open("config.tmp", "w") do |io|
                io << File.read(file_name).gsub("@import Foundation;", "#import <Foundation/Foundation.h>").gsub("@import Security;", "#import <Security/Security.h>")
            end
            FileUtils.mv("config.tmp", file_name)
        end

        #IFTTT
        file_names = [
        "#{workDir}/Pods/JazzHands/JazzHands/IFTTTJazzHands.h",
        "#{workDir}/Pods/JazzHands/JazzHands/IFTTTAnimation.h",
        "#{workDir}/Pods/JazzHands/JazzHands/IFTTTAnimationFrame.h",
        "#{workDir}/Pods/JazzHands/JazzHands/IFTTTEasingFunction.h",
        "#{workDir}/Pods/JazzHands/JazzHands/IFTTTAnimatedScrollViewController.h"
        ]
        file_names.each do |file_name|
            File.open("config.tmp", "w") do |io|
                io << File.read(file_name)
                .gsub("@import Foundation;", "#import <Foundation/Foundation.h>")
                .gsub("@import UIKit;", "#import <UIKit/UIKit.h>")
                .gsub("@import QuartzCore;", "#import <QuartzCore/QuartzCore.h>")
            end
            FileUtils.mv("config.tmp", file_name)
        end
    end

    def adjust_compiler_optimization_for_debug(installer)
        installer.pods_project.build_configurations.each do |config|
            if config.name.include?("Debug")
                config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
            end
        end
    end

    def disable_bitcode(installer)
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
              config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end

    puts "Adjusting compiler optimization for debug ..."
    adjust_compiler_optimization_for_debug(installer)
    
    puts "Adapting GCM library for Objective-c++ ..."
    remove_xcode_6_module_import_for_objcPlusPlus

    puts "disabling bitcode ..."
    disable_bitcode(installer)
end
