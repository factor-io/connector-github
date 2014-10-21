require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_issues' do
  action 'list' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo_name']
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
      "Unable to connect to Github"
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

    issues = github.issues.list payload

    action_callback issues
  end
end
