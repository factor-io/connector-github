require 'spec_helper'

describe 'github_repo' do

  before(:all) do
    @api_key = ENV['GITHUB_API_KEY']
    @params = {
      'api_key' => @api_key,
      'username' => 'skierkowski',
      'repo'    => 'hello',
      'branch'  => 'master'
    }
  end

  describe 'download' do
    it 'can download a repo' do
      service_instance = service_instance('github_repo')
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
