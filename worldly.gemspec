# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'worldly/version'

Gem::Specification.new do |spec|
  spec.name          = "worldly"
  spec.version       = Worldly::VERSION
  spec.authors       = ["Daniel Lewis"]
  spec.email         = ["webmaster@adventistmedia.org.au"]
  spec.summary       = %q{Country address formatting and telephone information}
  spec.description   = %q{Get country address formatting rules and local fields for forms. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake"
end
