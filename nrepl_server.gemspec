
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nrepl_server/version"

Gem::Specification.new do |spec|
  spec.name          = "nrepl_server"
  spec.version       = NReplServer::VERSION
  spec.authors       = ["Ruin0x11"]
  spec.email         = ["ipickering2@gmail.com"]

  spec.summary       = "An nREPL server for Ruby."
  spec.homepage      = "https://github.com/Ruin0x11/nrepl_server"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bencode", "~> 0.7.0"
  spec.add_dependency "eventmachine", "~> 1.2.7"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
end
