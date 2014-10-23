require 'spec_helper'

describe 'github_issues' do

  before(:all) do
    @api_key       = ENV['GITHUB_APIKEY']
    @username
    @repo          = 'andrewrdakers/working_with_github_api'
    @filter        = 'created'
    @state         = 'closed'
    @since         = '2011-04-12T12:12:12Z'
    @find_labels   = ['bug','wontfix']
    @list_labels   = 'bug,enhancement'
    @sort          = 'comments'
    @direction     = 'asc'
    @title         = 'title-' + Random.rand(9999).to_s
    @body          = 'body-' + Random.rand(9999).to_s
    @assignee      = 'andrewrdakers'
    @number        = 42
    @updated_title = @title + ' updated_title- ' + Random.rand(9999).to_s
    @updated_body  = @body + ' updated_body- ' + Random.rand(9999).to_s
    if @repo
      @username, @repo = @repo.split('/') if @repo.include?('/') && !@username
      @repo, @branch   = @repo.split('#') if @repo.include?('#') && !@branch
      @branch         ||= 'master'
    end
  end

  after(:all) do
    github = Github.new oauth_token: @api_key
    github_wrapper = github.issues.list user: @username, repo: @repo
    issues = []
    github_wrapper.body.each { |mash| issues << mash.to_hash }
    @closing_number = issues[0]['number']
    github_wrapper = github.issues.edit @username, @repo, @closing_number, state: @state
  end

  describe 'list' do
    it 'can list all the issues' do
      service_instance = service_instance('github_issues')
      params = {
        'api_key'   => @api_key,
        'username'  => @username,
        'repo'      => @repo,
        'filter'    => @filter,
        'state'     => @state,
        'since'     => @since,
        'labels'    => @list_labels,
        'sort'      => @sort,
        'direction' => @direction
      }
      service_instance.test_action('list', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
      end
    end
  end

  describe 'find' do
    it 'can find a single issue' do
      service_instance = service_instance('github_issues')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'number'   => @number
      }
      service_instance.test_action('find', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
      end
    end
  end

  describe 'create' do
    it 'can create a new issue' do
      service_instance = service_instance('github_issues')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'title'    => @title,
        'body'     => @body,
        'labels'   => @find_labels,
        'assignee' => @assignee
      }
      service_instance.test_action('create', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
      end
    end
  end

  describe 'edit' do
    it 'can update an issue' do
      service_instance = service_instance('github_issues')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'title'    => @updated_title,
        'body'     => @updated_body,
        'state'    => @state,
        'labels'   => @find_labels,
        'number'   => @number
      }
      service_instance.test_action('edit', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
      end
    end
  end
end
