require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_deployments' do
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

    info 'Getting all deployments'
    begin
      deployments = []
      github_wrapper = github.repos.deployments.list username, repo
      github_wrapper.body.each { |mash| deployments << mash.to_hash }
    rescue
      fail 'Unable to get the deployment'
    end

    action_callback deployments
  end

  action 'create' do |params|
    api_key     = params['api_key']
    username    = params['username']
    repo        = params['repo']
    ref         = params['ref']

    fail 'API Key (api_key) is required' unless api_key
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo
    fail 'Ref (ref) is required' unless ref
    
    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    tag_options = %w(ref task auto_merge required_contexts payload environment description force)

    deployment_params = {} 
    params.each do |key,value|
      deployment_params[key.to_sym] = value if tag_options.include?(key)
    end

    begin
      status = github.repos.deployments.create username, repo, deployment_params
    rescue
      fail 'Failed to create the deployment'
    end
    action_callback status.body.to_hash
  end

  action 'statuses' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    id        = params['id']

    fail 'API Key must be defined' unless api_key
    fail 'Deployment ID (id) is required' unless id

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    info 'Getting all deployments'
    begin
      deployment_statuses = []
      github_wrapper = github.repos.deployments.statuses username, repo, id
      github_wrapper.body.each { |mash| deployment_statuses << mash.to_hash }
    rescue
      fail 'Unable to get the deployment'
    end

    action_callback deployment_statuses
  end

  action 'create_status' do |params|
    api_key     = params['api_key']
    username    = params['username']
    repo        = params['repo']
    id          = params['id']

    fail 'API Key (api_key) is required' unless api_key
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo
    fail 'Deployment ID (id) is required' unless id
    
    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    tag_options = %w(state target_url description)

    status_params = {} 
    params.each do |key,value|
      status_params[key.to_sym] = value if tag_options.include?(key)
    end

    begin
      status = github.repos.deployments.create_status username, repo, id, status_params
    rescue
      fail 'Failed to create the deployment status'
    end
    action_callback status.body.to_hash
  end
end
