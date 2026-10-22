lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vue_uk/version'

Gem::Specification.new do |spec|
  spec.name          = 'vue_uk'
  spec.version       = VueUk::VERSION
  spec.authors       = ['Andy Croll']
  spec.email         = ['andy@goodscary.com']
  spec.description   = 'Pull movie & cinema information from the Vue cinemas website API'
  spec.summary       = "It's a scraper, but a nice one"
  spec.homepage      = 'https://github.com/andycroll/vue_uk'
  spec.licenses      = %w(AGPL MIT)

  spec.required_ruby_version = '>= 3.4'

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'minitest-mock'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov', '< 1'
  spec.add_development_dependency 'webmock'

  spec.add_runtime_dependency 'cinebase', '~> 5.4'
end
