require 'spec_helper'

describe GithubConnectorDefinition do
  describe :status do
    it 'can list all releases' do
      @runtime.run([:status,:list],api_key: @api_key, repo:"#{@user}/#{@repo}#master")
      expect(@runtime).to respond
    end

    it 'can create a status' do
      options = {
        api_key:     @api_key,
        repo:        "#{@user}/#{@repo}#master",
        sha:         'ee008674a5c16f95e5cd0a2f30610a899d01c60f',
        context:     'factor',
        state:       'pending',
        description: 'deploying'
      }
      @runtime.run([:status,:create],options)

      expect(@runtime).to respond
      
    end
  end
end
