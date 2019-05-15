# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

target 'VisionDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VisionDemo
  pod 'TesseractOCRiOS'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
#        if target.name == 'SwiftOCR'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
#        end
    end
end

