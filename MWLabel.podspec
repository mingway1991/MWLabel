Pod::Spec.new do |s|
  s.name             = 'MWLabel'
  s.version          = '0.1.4'
  s.summary          = 'A short description of MWLabel.'
  s.description      = '基于CoreText实现的Label'

  s.homepage         = 'https://github.com/mingway1991/MWLabel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mingway1991' => 'shimingwei@lvmama.com' }
  s.source           = { :git => 'https://github.com/mingway1991/MWLabel.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MWLabel/Classes/**/*'
  s.frameworks = 'UIKit', 'CoreText'
end
