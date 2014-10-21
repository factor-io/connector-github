require 'spec_helper'

describe 'github' do

  before(:all) do
    @api_key   = ENV['GITHUB_APIKEY']
    @username  = 'andrewrdakers'
    @repo_name = 'working_with_github_api'
    @filter    = 'created'
    @state     = 'open'
    @since     = '2011-04-12T12:12:12Z'
    @labels    = 'enhancement'
    @sort      = 'comments'
    @direction = 'asc'
  end

  describe 'list' do
    it 'can list all the issues' do
      service_instance = service_instance('github_issues')
      params = {
        'api_key'   => @api_key,
        'username'  => @username,
        'repo_name' => @repo_name,
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
end
