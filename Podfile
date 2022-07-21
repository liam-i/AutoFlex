source 'https://cdn.cocoapods.org/'

install! 'cocoapods',
  :disable_input_output_paths => true,
  :generate_multiple_pod_projects => true

platform :ios, '10.0'
#use_frameworks!
use_frameworks! :linkage => :static

target 'AutoLayout_Example' do
  pod 'LPAutoLayout', :path => './'

  target 'AutoLayout_Tests' do
    inherit! :search_paths
    
  end
end
