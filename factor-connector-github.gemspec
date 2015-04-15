# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-github'
  s.version       = '3.0.0'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski', 'Andrew Akers']
  s.email         = ['maciej@factor.io', 'andrewrdakers@gmail.com']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Github Factor.io Connector'
  s.files         = ['lib/factor-connector-github.rb']

  s.require_paths = ['lib']

  s.add_runtime_dependency 'github_api', '~> 0.12.3'
  s.add_runtime_dependency 'websockethook', '~> 0.1.01'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end
