require 'codeclimate-test-reporter'
require 'rspec'
require 'factor/connector/test'
require 'factor/connector/runtime'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-github'

RSpec.configure do |c|
  c.include Factor::Connector::Test

  c.before :all do
    @user = 'skierkowski'
    @repo = 'hello'
    @api_key = ENV['GITHUB_API_KEY']
    @github = Github.new oauth_token: @api_key
  end

  c.before :each do
    new_runtime
  end

  c.after :each do
    @runtime.logs.clear
  end

  def new_runtime
    @runtime = Factor::Connector::Runtime.new(GithubConnectorDefinition)
  end

  def create_issue(options={})
    user = options[:user] || @user
    repo = options[:repo] || @repo
    title = options[:title]
    @github.issues.create(user:user, repo:repo, title:title).to_hash
  end

  def close_issue(options = {})
    user = options[:user] || @user
    repo = options[:repo] || @repo
    number = options[:number]
    @github.issues.edit(user, repo, number, state: 'closed').to_hash
  end

  def get_issue(options = {})
    user = options[:user] || @user
    repo = options[:repo] || @repo
    number = options[:number]
    @github.issues.get(user:user, repo:repo, number: number).to_hash
  end

end
