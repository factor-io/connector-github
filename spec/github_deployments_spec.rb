require 'spec_helper'

describe GithubConnectorDefinition do
  describe :deployment do
    context 'with a deployment' do
      before :all do
        @deployment = create_deployment
      end

      it :list do
        @runtime.run([:deployment,:list],api_key: @api_key, repo:"#{@user}/#{@repo}")
        expect(@runtime).to respond
        last =  @runtime.logs.last
        expect(last[:data]).to be_a(Array)

      end

      it :statuses do
        @runtime.run([:deployment,:statuses],api_key: @api_key, repo:"#{@user}/#{@repo}#master", deployment:@deployment['id'])
        expect(@runtime).to respond
      end

      it :create_status do
        @runtime.run([:deployment,:create_status],api_key: @api_key, repo:"#{@user}/#{@repo}#master", deployment:@deployment['id'], state:'success')
        expect(@runtime).to respond
      end
    end

    context 'without a deployment' do
      it :create do
        @runtime.run([:deployment,:create],api_key: @api_key, repo:"#{@user}/#{@repo}#master")
        expect(@runtime).to respond
        last =  @runtime.logs.last
        expect(last[:data]).to include('id')
        expect(last[:data]).to include('sha')
        expect(last[:data]).to include('ref')
        expect(last[:data]).to include('task')
        expect(last[:data]).to include('payload')
        expect(last[:data]).to include('environment')
        expect(last[:data]).to include('description')
        expect(last[:data]).to include('creator')
        expect(last[:data]).to include('statuses_url')
        expect(last[:data]).to include('repository_url')
      end
    end
  end
end
