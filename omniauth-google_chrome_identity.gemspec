lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/google_chrome_identity/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-google_chrome_identity"
  spec.version       = Omniauth::GoogleChromeIdentity::VERSION
  spec.authors       = ["Ignacio Galindo"]
  spec.email         = ["email@joiggama.net"]

  spec.summary       = %q{OmniAuth strategy for google chrome identity API}
  spec.description   = %q{Provides access_token only callback phase}
  spec.homepage      = "https://github.com/joiggama/omniaith-google_chrome_identity"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth2",     "~> 1.1"
  spec.add_dependency "omniauth",   "~> 1.2"
  spec.add_dependency "omniauth-oauth2", "1.3.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
