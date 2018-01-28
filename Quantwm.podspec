#
# Be sure to run `pod lib lint Quantwm.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Quantwm'
  s.version          = '0.3.0'
  s.summary          = 'Quantwm is a Data Model access layer, which send ordered notifications'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Quantwm is an architecture framework, which enforces a lot of rules to eliminate common sources of variability inside a complex application. View Controllers shall only communicate synchronously with the Model, and Quantwm will schedule the notifications inside the event loop first with a hard-coded priority to update the view hierarchy, then according to property depedency to update view content.
The decoupling help building a clean architecture, with a clear contract and context associated to each entity:
- Source: Writing an event in the model
- Hard-coded priority processing: Either coordinate and update the view hierarchy, or process the model data.
- Property dependent processing: Register to Read{A,B} and Write {C}. Is only allowed to Read A and B and Write C.
- Property dependent sink: Registered view will update their content once all the previous processing has cleanly formatted the data.
                       DESC

  s.homepage         = 'https://github.com/xlasne/Quantwm'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xlasne' => 'xavier.lasne@gmail.com' }
  s.source           = { :git => 'https://github.com/xlasne/Quantwm.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target  = '10.11'

  s.source_files = 'Quantwm/Classes/**/*'

  # s.resource_bundles = {
  #   'Quantwm' => ['Quantwm/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
