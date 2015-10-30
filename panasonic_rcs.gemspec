# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'panasonic_rcs/version'

Gem::Specification.new do |spec|
  spec.name          = "panasonic_rcs"
  spec.version       = PanasonicRcs::VERSION
  spec.authors       = ["Emery A. Miller"]
  spec.email         = ["emiller@jive.com"]
  spec.summary       = %q{A component to make XMLRPC calls to Panasonic's RCS service}
  spec.description   = %q{A ruby wrapper around Panasonic's XMLRPC RCS service}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"
  spec.add_runtime_dependency "multi_xml"
end
