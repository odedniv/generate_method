# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'generate_method/version'

Gem::Specification.new do |spec|
  spec.name          = "generate_method"
  spec.version       = GenerateMethod::VERSION
  spec.authors       = ["Oded Niv"]
  spec.email         = ["oded.niv@gmail.com"]
  spec.summary       = %q{Nicely generate methods on a Class or Module.}
  spec.description   = %q{Allow your gem users to override your generated methods nicely.}
  spec.homepage      = "https://github.com/odedniv/generate_method"
  spec.license       = "UNLICENSE"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec", "~> 3.1"
end
