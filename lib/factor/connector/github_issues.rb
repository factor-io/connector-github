require 'factor-connector-api'
require 'github_api'

Factor::Connector.service 'github_issues' do
  action 'list' do |params|
    api_key   = params['api_key']
    username  = params['username']
    repo      = params['repo_name']
    filter    = params['filter'] #default: assigned
    state     = params['state'] #default: open
    since     = params['since']
    labels    = params['labels']
    sort      = params['sort']
    direction = params['direction'] #default: desc

    fail 'API Key must be defined' unless api_key

    begin
      github = Github.new oauth_token: api_key
    rescue
      "Unable to connect to github"
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
    puts "params: #{params}"

    begin
      issues = github.issues.list payload
      puts "issues: #{issues}"
    rescue => ex
      fail "exception: #{ex}"
    end

    action_callback issues
  end
end
