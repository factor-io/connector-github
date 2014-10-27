require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_issues' do
  action 'list' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo']
    filter    = params['filter']
    state     = params['state']
    since     = params['since']
    labels    = params['labels']
    sort      = params['sort']
    direction = params['direction']

    fail 'API Key must be defined' unless api_key

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    payload = {
      user: username,
      repo: repo,
      filter: filter,
      state: state,
      since: since,
      labels: labels,
      sort: sort,
      direction: direction
    }

    github_wrapper = github.issues.list payload

    issues = []

    github_wrapper.body.each { |mash| issues << mash.to_hash }

    action_callback issues
  end

  action 'get' do |params|
    api_key  = params['api_key']
    username = params['username']
    repo     = params['repo']
    id       = params['id']

    if repo
      username, repo = repo.split('/') if repo.include?('/') && !username
      repo, branch   = repo.split('#') if repo.include?('#') && !branch
      branch         ||= 'master'
    end


    fail 'API key must be defined' unless api_key
    fail 'Username must be defined' unless username
    fail 'Repository must be defined' unless repo

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      'Unable to connect to Github'
    end

    payload = {}
    payload[:user] = username
    payload[:repo] = repo
    payload[:number] = id

    info 'Updating issue'
    begin
      github_wrapper = github.issues.get payload
      issue = github_wrapper.to_hash
    rescue
      fail 'Unable to get the issue'
    end

    action_callback issue
  end

  action 'create' do |params|
    api_key  = params['api_key']
    username = params['username']
    repo     = params['repo']
    title    = params['title']
    body     = params['body']
    labels   = params['labels']
    assignee = params['assignee']

    if repo
      username, repo = repo.split('/') if repo.include?('/') && !username
      repo, branch   = repo.split('#') if repo.include?('#') && !branch
      branch         ||= 'master'
    end

    fail 'API key must be defined' unless api_key
    fail 'Title must be defined' unless title
    fail 'Username must be defined' unless username
    fail 'Repository must be defined' unless repo

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    payload = {}
    payload[:user] = username
    payload[:repo] = repo
    payload[:title] = title
    payload[:body] = body if body
    payload[:assignee] = assignee if assignee
    payload[:labels] = labels if labels

    info 'Creating new issue'
    begin
      github_wrapper = github.issues.create payload
      issue = github_wrapper.to_hash
    rescue
      fail 'Unable to create the issue'
    end

    info 'Issue has been created'

    action_callback issue
  end

  action 'edit' do |params|
    api_key  = params['api_key']
    username = params['username']
    repo     = params['repo']
    title    = params['title']
    body     = params['body']
    number   = params['id']
    state    = params['state']
    labels   = params['labels']

    if repo
      username, repo = repo.split('/') if repo.include?('/') && !username
      repo, branch   = repo.split('#') if repo.include?('#') && !branch
      branch         ||= 'master'
    end

    fail 'API key must be defined' unless api_key
    fail 'Title must be defined' unless title
    fail 'Username must be defined' unless username
    fail 'Repository must be defined' unless repo

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end

    update = {}
    update[:title] = title if title
    update[:body] = body if body
    update[:state] = state if state
    update[:labels] = labels if labels

    info 'Updating your issue'
    begin
      github_wrapper = github.issues.edit username, repo, number, update
      issue = github_wrapper.to_hash
    rescue
      fail 'Unable to update the issue'
    end

    info 'Issue has been updated'

    action_callback issue
  end
end
