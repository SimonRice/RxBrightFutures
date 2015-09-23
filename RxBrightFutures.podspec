Pod::Spec.new do |s|
  s.name = 'RxBrightFutures'
  s.version = '0.9'
  s.license = 'MIT'
  s.summary = 'RxSwift wrapper around the Future/Promise library BrightFutures'
  s.homepage = 'https://github.com/SideEffects-xyz/RxBrightFutures'
  s.authors = { 'Junior B.' => 'info@bonto.ch' }
  s.source = { :git => 'git@github.com:SideEffects-xyz/RxBrightFutures.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Source/*.swift'

  s.requires_arc = true

  s.dependency = "BrightFutures", "~> 3.0.0-beta"
  s.dependency = "RxSwift", "~> 2.0.0-alpha"
end