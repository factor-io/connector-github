require 'spec_helper'

describe 'github_issue' do

  before(:all) do
    @api_key       = ENV['GITHUB_API_KEY']
    @username      = 'skierkowski'
    @branch        = 'master'
    @repo          = 'skierkowski/hello'
    @filter        = 'created'
    @state         = 'closed'
    @since         = '2011-04-12T12:12:12Z'
    @find_labels   = ['bug', 'wontfix']
    @list_labels   = 'bug,enhancement'
    @sort          = 'comments'
    @direction     = 'asc'
    @title         = 'title-' + Random.rand(9999).to_s
    @body          = 'body-' + Random.rand(9999).to_s
    @assignee      = @username
    @updated_title = @title + ' updated_title- ' + Random.rand(9999).to_s
    @updated_body  = @body + ' updated_body- ' + Random.rand(9999).to_s
    if @repo
      @username, @repo = @repo.split('/') if @repo.include?('/') && !@username
      @repo, @branch   = @repo.split('#') if @repo.include?('#') && !@branch
      @branch         ||= 'master'
    end
  end

  before(:each) do
    issues = []
    payload = {}
    payload[:user] = @username
    payload[:repo] = @repo
    payload[:title] = @title
    @github = Github.new oauth_token: @api_key
    github_wrapper = @github.issues.create payload
    issues << github_wrapper.to_hash
    @id = issues[0]['number']
  end

  after(:each) do
    github_wrapper = @github.issues.edit @username, @repo, @id, state: 'closed'
  end

  describe 'list' do
    it 'can list all the issues' do
      service_instance = service_instance('github_issue')
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
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Array)
      end
    end
  end

  describe 'get' do
    it 'can find a single issue' do
      service_instance = service_instance('github_issue')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'id'       => @id
      }
      service_instance.test_action('get', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Hash)
      end
    end
  end

  describe 'create' do
    it 'can create a new issue' do
      service_instance = service_instance('github_issue')
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
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Hash)
      end
    end
  end

  describe 'edit' do
    it 'can update an issue' do
      service_instance = service_instance('github_issue')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'title'    => @updated_title,
        'body'     => @updated_body,
        'state'    => @state,
        'labels'   => @find_labels,
        'id'       => @id
      }
      service_instance.test_action('edit', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Hash)
      end
    end
  end

  describe 'close' do
    it 'will close an issue' do
      service_instance = service_instance('github_issue')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'id'       => @id,
        'state'    => @state
      }
      service_instance.test_action('close', params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Hash)
      end
    end
  end
end
