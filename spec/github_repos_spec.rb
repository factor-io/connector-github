require 'spec_helper'

describe 'github_repos' do

  before(:all) do
    @api_key  = ENV['GITHUB_APIKEY']
    @username = 'andrewrdakers'
    @repo     = 'working_with_github_api'
    @branch   = 'master'
  end

  describe 'download' do
    it 'can download a repo' do
      service_instance = service_instance('github_repos')
      params = {
        'api_key'  => @api_key,
        'username' => @username,
        'repo'     => @repo,
        'branch'   => @branch
      }
      service_instance.test_action('download', params) do
        expect_return
      end
    end
  end
end
