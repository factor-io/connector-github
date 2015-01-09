require 'spec_helper'

describe 'github_repo' do

  before(:all) do
    @params = {
      'api_key' => @api_key,
      'repo'    => 'skierkowski/hello',
      'branch'  => 'master'
    }
  end

  describe 'download' do
    it 'can download a repo' do
      service_instance = service_instance('github_repo')
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
