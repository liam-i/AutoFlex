#
# Be sure to run `pod lib lint AutoLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LPAutoLayout'
  s.version          = '0.1.5'
  s.summary          = 'Auto layout framework.'

  s.description      = <<-DESC
                        An auto layout framework.
                       DESC

  s.homepage         = 'https://github.com/liam-i/AutoLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Liam' => 'liam_i@163.com' }
  s.source           = { :git => 'https://github.com/liam-i/AutoLayout.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.1', '5.2', '5.3']

  s.source_files = 'Sources/Classes/**/*'

  # s.resource_bundles = {
  #   'AutoLayout' => ['Sources/Assets/*.png']
  # }

  # s.public_header_files = 'Sources/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'Alamofire', '~> 5.4.4'
end
