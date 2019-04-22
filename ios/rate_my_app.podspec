#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'rate_my_app'
  s.version          = '0.1'
  s.summary          = 'Allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).'
  s.description      = <<-DESC
Allows to kindly ask users to rate your app.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

