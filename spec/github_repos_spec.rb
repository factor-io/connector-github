require 'spec_helper'

describe 'github_repos' do

  before(:all) do
    @params = {
      'api_key' => ENV['GITHUB_APIKEY'],
      'repo'    => 'andrewrdakers/working_with_github_api',
      'branch'  => 'master'
    }
  end

  describe 'download' do
    it 'can download a repo' do
      service_instance = service_instance('github_repos')
      @params
      service_instance.test_action('download', @params) do
        return_info = expect_return
        expect(return_info).to be_a(Hash)
        expect(return_info).to include(:payload)
        expect(return_info[:payload]).to be_a(Hash)
        expect(return_info[:payload]).to include(:content)
      end
    end
  end
end
