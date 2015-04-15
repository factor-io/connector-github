require 'spec_helper'

describe GithubConnectorDefinition do
  describe 'Statuses' do
    it 'can list all releases' do      
      # params = {
      #   'api_key'  => @api_key,
      #   'username' => 'skierkowski',
      #   'repo'     => 'hello',
      #   'ref'      => 'master'
      # }
      # @scope.test_action('list', params) do
      #   return_info = expect_return[:payload]
      #   expect(return_info).to be_a(Array)
      #   return_info.each do |release|
      #     expect(release).to be_a(Hash)
      #   end
      # end
    end

    it 'can create a status' do
      # github = Github.new oauth_token: @api_key

      # params = {
      #   'api_key'  => @api_key,
      #   'username' => 'skierkowski',
      #   'repo'     => 'hello',
      #   'sha'      => 'ee008674a5c16f95e5cd0a2f30610a899d01c60f',
      #   'context'  => 'factor',
      #   'state'    => 'pending',
      #   'description' => "deploying"
      # }
      # @scope.test_action('create', params) do
      #   return_info = expect_return[:payload]
      #   expect(return_info).to be_a(Hash)
      # end
    end
  end
end
