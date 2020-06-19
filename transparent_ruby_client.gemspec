# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'transparent_ruby_client'
  s.version = '0.1.2'
  s.date = '2020-06-15'
  s.summary       = 'A ruby client for https://listingroiapi.seetransparent.com/'
  s.description   = 'A ruby client for https://listingroiapi.seetransparent.com/'
  s.require_paths = ['lib']
  s.authors       = ['Lavanda']
  s.files         = Dir['lib/transparent.rb', 'lib/**/*']
  s.homepage      = 'https://rubygems.org/gems/transparent_ruby_client'
  s.license       = 'MIT'

  s.add_runtime_dependency     'sorbet-runtime', '~> 0.5'

  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rubocop', '~> 0.85.1'
  s.add_development_dependency 'sorbet', '~> 0.5'
  s.add_development_dependency 'typhoeus', '~> 1.4'
  s.add_development_dependency 'webmock', '~> 3.8'
end
