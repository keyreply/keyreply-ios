#
# Be sure to run `pod lib lint KeyReply.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeyReply'
  s.version          = '0.0.13'
  s.summary          = 'KeyReply SDK for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
KeyReply is your top choice for chatbots: We have worked with top governments and enterprises in Singapore and Asia.
                       DESC

  s.homepage         = 'https://github.com/keyreply/keyreply-ios'
  s.screenshots      = 'https://github.com/keyreply/keyreply-ios/blob/master/example_screenshot.png?raw=true'
  s.license          = { :type =>  'MIT', :file => 'LICENSE' }
  s.author           = { 'KeyReply' => 'developer@keyreply.com' }
  s.source           = { :git => 'https://github.com/keyreply/keyreply-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'KeyReply/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KeyReply' => ['KeyReply/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
