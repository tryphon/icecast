# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icecast/version'

Gem::Specification.new do |spec|
  spec.name          = "icecast"
  spec.version       = Icecast::VERSION
  spec.authors       = ["Alban Peignier", "Florent Peyraud"]
  spec.email         = ["alban@tryphon.eu", "florent@tryphon.eu"]
  spec.description   = %q{A ruby interface to Icecast API}
  spec.summary       = %q{Connect to icecast admin interface to manage resources}
  spec.homepage      = "http://projects.tryphon.eu/projects/ruby-icecast"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'null_logger'

  spec.add_development_dependency "bundler", "~> 1.3"

  spec.add_development_dependency 'rake'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "fakeweb"

end
