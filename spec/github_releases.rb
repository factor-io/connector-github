require 'spec_helper'

describe 'Github' do
  describe 'Releases' do
    before(:all) do
      @scope = service_instance('github_releases')
    end

    it 'can list all releases' do      
      params = {
        'api_key' => @api_key,
        'username' => 'skierkowski',
        'repo'    => 'hello'
      }
      @scope.test_action('list', params) do
        return_info = expect_return[:payload]
        expect(return_info).to be_a(Array)
        return_info.each do |release|
          expect(release).to be_a(Hash)
        end
      end
    end

    it 'can get a release by id' do
      github = Github.new oauth_token: @api_key
      release = github.repos.releases.create 'skierkowski', 'hello', 'test', name:'Test for test'
      params = {
        'api_key'  => @api_key,
        'username' => 'skierkowski',
        'repo'     => 'hello',
        'id'       => release.id
      }
      @scope.test_action('get', params) do
        return_info = expect_return[:payload]
        expect(return_info).to be_a(Hash)
      end
    end

    it 'can create a release' do
      github = Github.new oauth_token: @api_key

      params = {
        'api_key'  => @api_key,
        'username' => 'skierkowski',
        'repo'     => 'hello',
        'name'     => 'Release for v0.0.2',
        'tag_name' => 'test',
        'prerelease' => true
      }
      @scope.test_action('create', params) do
        return_info = expect_return[:payload]
        expect(return_info).to be_a(Hash)
        github.repos.releases.delete 'skierkowski', 'hello', return_info['id']
      end
    end

    it 'can delete a release' do
      github = Github.new oauth_token: @api_key
      release = github.repos.releases.create 'skierkowski', 'hello', 'test', name:'Test for test', prerelease: true

      params = {
        'api_key'  => @api_key,
        'username' => 'skierkowski',
        'repo'     => 'hello',
        'id'       => release.id
      }
      @scope.test_action('delete', params) do
        return_info = expect_return[:payload]
        expect(return_info).to be_a(Hash)

        expect { github.repos.releases.get 'skierkowski', 'hello', release.id }.to raise_error(Github::Error::NotFound)
      end
    end
  end
end
