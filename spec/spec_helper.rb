require 'codeclimate-test-reporter'
require 'rspec'
require 'factor/connector/test'
require 'factor/connector/runtime'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-github'

RSpec.configure do |c|
  c.include Factor::Connector::Test

  c.before :all do
    @api_key = ENV['GITHUB_API_KEY']
    @runtime = Factor::Connector::Runtime.new(GithubConnectorDefinition)
    @github = Github.new oauth_token: @api_key
  end
end
