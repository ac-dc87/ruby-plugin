
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby/plugin/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-plugin"
  spec.version       = Ruby::Plugin::VERSION
  spec.authors       = ["Emir Ibrahimbegovic"]
  spec.email         = ["IbrahimbegovicEmir@prahs.com", "emir.ibrahimbegovic@gmail.com"]

  spec.summary       = %q{Plugin engine for 3rd party integration with rabbitMQ bus}
  spec.homepage      = "http://prahs.com"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'hashie'

  spec.add_runtime_dependency "foreman"
  spec.add_runtime_dependency "sneakers"
  spec.add_runtime_dependency "httparty", '~> 0.13.5'
end
