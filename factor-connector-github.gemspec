# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-github'
  s.version       = '0.0.6'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski', 'Andrew Akers']
  s.email         = ['maciej@factor.io', 'andrewrdakers@gmail.com']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Github Factor.io Connector'
  s.files         = Dir.glob('lib/factor/connector/*.rb')

  s.require_paths = ['lib']

  s.add_runtime_dependency 'github_api', '~> 0.12.2'
  s.add_runtime_dependency 'factor-connector-api', '~> 0.0.14'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.5'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end
