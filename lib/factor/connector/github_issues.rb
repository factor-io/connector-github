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
      'Unable to connect to Github'
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

  action 'create' do |params|
    api_key  = params['api_key']
    username = params['username']
    repo     = params['repo']
    title    = params['title']
    body     = params['body']

    fail 'API key must be defined' unless api_key
    fail 'Issue must have a title' unless title

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key, user: username, repo: repo
    rescue
      'Unable to connect to Github'
    end

    info 'Creating new issue'
    begin
      issue = github.issues.create title: title, body: body
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
    number   = params['number']

    fail 'API key must be defined' unless api_key
    fail 'Issue must have a title' unless title

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key, user: username, repo: repo
    rescue
      'Unable to connect to Github'
    end

    info 'Updating your issue'
    begin
      issue = github.issues.edit username, repo, number, title: title, body: body
    rescue
      fail 'Unable to update the issue'
    end

    info 'Issue has been updated'

    action_callback issue
  end
end
