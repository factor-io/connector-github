require 'spec_helper'

describe 'github' do

  before(:all) do
    @api_key   = ENV['GITHUB_APIKEY']
    @username  = 'andrewrdakers'
    @repo      = 'working_with_github_api'
    @filter    = 'created'
    @state     = 'open'
    @since     = '2011-04-12T12:12:12Z'
    @labels    = 'enhancement'
    @sort      = 'comments'
    @direction = 'asc'
    @title     = 'title-' + Random.rand(9999).to_s
    @body      = 'body-' + Random.rand(9999).to_s
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
        'labels'    => @labels,
        'sort'      => @sort,
        'direction' => @direction
      }
      service_instance.test_action('list', params) do
        expect_return
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
        'body'     => @body
      }
      service_instance.test_action('create', params) do
        expect_return
      end
    end
  end
end
