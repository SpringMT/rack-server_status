# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/server_status/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-server_status"
  spec.version       = Rack::ServerStatus::VERSION
  spec.authors       = ["SpringMT"]
  spec.email         = ["today.is.sky.blue.sky@gmail.com"]

  #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  spec.required_rubygems_version = ">= 2.0"

  spec.summary       = %q{Show server status}
  spec.description   = %q{Show server status}
  spec.homepage      = "https://github.com/SpringMT/rack-server_status"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|examples)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "worker_scoreboard"
  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec"

end
