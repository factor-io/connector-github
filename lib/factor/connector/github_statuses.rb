require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_statuses' do
  action 'list' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    ref       = params['ref']

    fail 'API Key must be defined' unless api_key
    fail 'Ref (ref) must be defined' unless ref

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    info 'Getting all statuses'
    begin
      statuses = []
      github_wrapper = github.repos.statuses.list username, repo, ref
      github_wrapper.body.each { |mash| statuses << mash.to_hash }
    rescue
      fail 'Unable to get the statuses'
    end

    action_callback statuses
  end

  action 'create' do |params|
    api_key     = params['api_key']
    username    = params['username']
    repo        = params['repo']
    sha         = params['sha']
    state       = params['state']
    description = params['description']
    target_url  = params['target_url']
    context     = params['context'] || 'default'

    fail 'API Key (api_key) is required' unless api_key
    fail 'Username (username) is required' unless username
    fail 'Repo (repo) is required' unless repo
    fail 'SHA (sha) is required' unless sha
    fail 'State (state) is required' unless state

    allowed_states = %w{pending success error failure}

    fail "State (state) can only be #{allowed_states.join(',')}" unless allowed_states.include?(state)

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    tag_options = %w(state target_url description context)

    status_params = {} 
    params.each do |key,value|
      status_params[key.to_sym] = value if tag_options.include?(key)
    end

    begin
      status = github.repos.statuses.create username, repo, sha, status_params
    rescue
      fail 'Failed to update the status'
    end
    action_callback status.body.to_hash
  end
end
