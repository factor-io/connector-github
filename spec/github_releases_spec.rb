require 'spec_helper'

describe GithubConnectorDefinition do
  describe :releases do
    context 'with any release' do
      before :all do
        # @release = create_release tag:'test'
      end
      after :all do
        # delete_release(release:@release['id'])
      end
      it 'can :list' do
        @runtime.run([:release,:list],api_key: @api_key, repo:"#{@user}/#{@repo}")
        expect(@runtime).to respond
      end

      it 'can :get' do
        # @runtime.run([:release,:get],api_key: @api_key, repo:"#{@user}/#{@repo}", release: @release['id'])
        # expect(@runtime).to respond
      end
    end

    context 'with deleteable release' do
      before :each do
        # @release = create_release tag:'test'
      end

      it 'can :delete' do
        # @runtime.run([:release,:delete],api_key: @api_key, repo:"#{@user}/#{@repo}", release: @release['id'])
        # expect(@runtime).to respond
      end
    end

    context 'without release' do
      after :each do

      end
      it :create do


      end
    end
  end
end
