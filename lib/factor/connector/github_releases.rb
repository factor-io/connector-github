require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_releases' do
  action 'list' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']

    fail 'API Key must be defined' unless api_key

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    info 'Getting all releaes'
    begin
      releases = []
      github_wrapper = github.repos.releases.list username, repo
      github_wrapper.body.each { |mash| releases << mash.to_hash }
    rescue
      fail 'Unable to get the releases'
    end

    action_callback releases
  end

  action 'get' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    id        = params['id']

    fail 'API Key (api_key) is required' unless api_key
    fail 'ID (id) is required' unless id
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    info 'Getting all releaes'
    begin
      releases = []
      github_wrapper = github.repos.releases.get username, repo, id
      release = github_wrapper.body.to_hash
    rescue
      fail 'Unable to get the releases'
    end

    action_callback release
  end

  action 'create' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    tag_name  = params['tag_name']

    fail 'API Key (api_key) is required' unless api_key
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo
    fail 'Tag Name (tag_name) is required' unless tag_name

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    tag_options = %w(target_commitish body name draft prerelease)

    tag_params = {} 
    params.each do |key,value|
      tag_params[key.to_sym] = value if tag_options.include?(key)
    end

    begin
      release = github.repos.releases.create username, repo, tag_name, tag_params
      # release = github.repos.releases.create username, repo, tag_name, prerelease: true
    rescue
      fail 'Failed to tag the release'
    end

    action_callback release.body.to_hash

  end

  action 'delete' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    id        = params['id']

    fail 'API Key (api_key) is required' unless api_key
    fail 'ID (id) is required' unless id
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    info 'Getting all releaes'
    begin
      release = github.repos.releases.delete username, repo, id
    rescue
      fail 'Unable to get the releases'
    end

    action_callback
  end

end
