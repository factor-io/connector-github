require 'spec_helper'

describe GithubConnectorDefinition do
  describe :issue do

    context 'with an existing issue' do
      before :each do
        @issue = create_issue(title:'sweet')
      end
      after :each do
        close_issue(number:@issue['number']) if @issue
      end

      it :list do
        @runtime.run([:issue,:list],api_key: @api_key, repo:"#{@user}/#{@repo}")
        expect(@runtime).to respond
        last =  @runtime.logs.last
        expect(last[:data]).to be_a(Array)
      end
      
      it :get do
        @runtime.run([:issue,:get],api_key: @api_key, repo:"#{@user}/#{@repo}", number: @issue['number'])
        expect(@runtime).to respond
      end

      it :close do
        @runtime.run([:issue,:close],api_key: @api_key, repo:"#{@user}/#{@repo}", number:@issue['number'])
        expect(@runtime).to respond
      end

      it :edit do
        @runtime.run([:issue,:edit],api_key: @api_key, repo:"#{@user}/#{@repo}", number:@issue['number'], title:'new title')
        expect(@runtime).to respond

        updated_issue = get_issue(number:@issue['number'])

        expect(updated_issue['title']).to eq('new title')  
      end
    end

    context 'without an existing issue' do
      after do
        close_issue(number:@issue['number']) if @issue
      end
      it :create do
        @runtime.run([:issue,:create],api_key: @api_key, repo:"#{@user}/#{@repo}", title:'sweet')
        expect(@runtime).to respond
        last  =  @runtime.logs.last
        @issue = last[:data]
      end
    end
  end
end
