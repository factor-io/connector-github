require 'spec_helper'

describe GithubConnectorDefinition do
  describe 'Repository' do
    describe 'download' do
      it 'can download a repo' do
        @runtime.run([:repo,:download],api_key: @api_key, repo:'skierkowski/hello')

        expect(@runtime).to respond
        last =  @runtime.logs.last

        expect(last[:data]).to include(:content)
      end
    end
  end
end
