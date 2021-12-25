# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-debug/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-debug'
  spec.version       = CocoapodsDebug::VERSION
  spec.authors       = ['bob']
  spec.email         = ['bob170731@gmail.com']
  spec.description   = %q{A short description of cocoapods-debug.}
  spec.summary       = %q{A longer description of cocoapods-debug.}
  spec.homepage      = 'https://github.com/EXAMPLE/cocoapods-debug'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rake',"~> 12.3"

  spec.add_dependency 'xcodeproj', '~> 1.10'
  spec.add_dependency 'cocoapods', '~> 1.8'
  spec.add_dependency 'cocoapods-core', '~> 1.8'
end
