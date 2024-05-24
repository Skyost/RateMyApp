#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rate_my_app.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rate_my_app'
  s.version          = '2.2.0'
  s.summary          = 'Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).'
  s.description      = <<-DESC
Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
                       DESC
  s.homepage         = 'https://github.com/Skyost/RateMyApp'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Skyost' => 'me@skyost.eu' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '10.3'
  s.osx.deployment_target = '10.14'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
