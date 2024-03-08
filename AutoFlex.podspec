#
# Be sure to run `pod lib lint AutoFlex.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AutoFlex'
  s.version          = '0.3.0'
  s.summary          = 'An auto layout framework.'

  s.description      = <<-DESC
                        A Swift Autolayout Library for iOS, tvOS and macOS.
                       DESC

  s.homepage         = 'https://github.com/liam-i/AutoFlex'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Liam' => 'liam_i@163.com' }
  s.source           = { :git => 'https://github.com/liam-i/AutoFlex.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.macos.deployment_target = '11.0'

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*'

  # s.resource_bundles = {
  #   'AutoFlex' => ['Sources/Assets/*.png']
  # }

  # s.public_header_files = 'Sources/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'Alamofire', '~> 5.4.4'
end
