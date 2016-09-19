#
# Be sure to run `pod lib lint NYPLCardCreator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NYPLCardCreator'
  s.version          = '0.1.0'
  s.summary          = 'A client and drop-in GUI for NYPL\'s RESTful card creator API'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
NYPLCardCreator implements a native registration flow for NYPL's card creator API. Users can
make their way through the registration flow in order to obtain a new library card.
                       DESC

  s.homepage         = 'https://github.com/NYPL-Simplified/CardCreator-iOS'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Winnie Quinn' => 'nypl@winniequinn.com' }
  s.source           = { :git => 'https://github.com/NYPL-Simplified/CardCreator-iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nypl_labs'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NYPLCardCreator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NYPLCardCreator' => ['NYPLCardCreator/Assets/*.png']
  # }

  s.frameworks = 'UIKit'
  s.dependency 'PureLayout', '~> 3.0'
end
