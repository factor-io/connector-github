require 'factor-connector-api'
require 'github_api'

github_events = [
  'commit_comment',
  'create',
  'delete',
  'deployment',
  'deployment_status',
  'download',
  'fork',
  'gollum',
  'issue_comment',
  'issues',
  'member',
  'page_build',
  'public',
  'pull_request',
  'pull_request_review_comment',
  'push',
  'release',
  'team_add',
  'watch']

Factor::Connector.service 'github_repo' do
  github_events.each do |github_event|
    listener github_event do
      start do |params|
        api_key        = params['api_key']
        username       = params['username']
        repo           = params['repo']
        branch         = params['branch']

        if repo
          username, repo = repo.split('/') if repo.include?('/') && !username
          repo, branch   = repo.split('#') if repo.include?('#') && !branch
          branch         ||= 'master'
        end

        fail 'API Key is required' unless api_key
        fail 'Username is required' unless username
        fail 'Repo is required' unless repo

        info 'connecting to Github'
        begin
          github = Github.new oauth_token: api_key
        rescue => ex
          fail 'Failed to connect to github. Try re-activating Github service.', exception: ex
        end

        hook_url = web_hook id: 'post_receive' do
          start do |_listener_start_params, hook_data, _req, _res|
            hook_branch = hook_data['ref'].split('/')[-1] if hook_data['ref']

            if hook_data['zen']
              info "Received ping for hook '#{hook_data['hook_id']}'."
              warn 'Not triggering a workflow since this is not a push.'
            elsif hook_branch != branch && github_event == 'push'
              warn 'Incorrect branch on hook'
              warn "expected: '#{branch}', got: '#{hook_branch}'"
            else
              access_query = "access_token=#{api_key}"

              info 'Getting the Archive URL of the repo'
              begin
                repo_reference = {
                  user: username,
                  repo: repo
                }
                github_repo = github.repos.get(repo_reference)
                archive_url_template = github_repo.archive_url
                uri_string = archive_url_template
                  .sub('{archive_format}', 'zipball')
                  .sub('{/ref}', "/#{branch}")
                download_ref_uri = URI(uri_string)
              rescue => ex
                fail 'Failed to get archive URL from Github', exception: ex
              end

              info "Downloading the repo from Github (#{download_ref_uri})"
              begin
                client          = Net::HTTP.new(
                  download_ref_uri.host,
                  download_ref_uri.port)
                client.use_ssl  = true
                download_uri    = "#{download_ref_uri.path}?#{access_query}"
                response        = client.get(download_uri)
                location        = response['location']
                trailing        = location.include?('?') ? '&' : '?'
                content_uri     = "#{location}#{trailing}#{access_query}"
                hook_data['content'] = URI(content_uri)
              rescue => ex
                fail 'Failed to download the repo from Github', exception: ex
              end

              start_workflow hook_data
            end
          end
        end

        info 'Checking for existing hook'
        begin
          hook = github.repos.hooks.list(username, repo).find do |h|
            h['config'] && h['config']['url'] && h['config']['url'] == hook_url
          end
        rescue => ex
          fail "Couldn't get list of existing hooks. Check username/repo."
        end

        unless hook
          info "Creating hook to '#{hook_url}' on #{username}/#{repo}."
          begin
            github_config = {
              'url' => hook_url,
              'content_type' => 'json'
            }
            github_settings = {
              'name' => 'web',
              'active' => true,
              'config' => github_config,
              'events' => github_event
            }
            repo_hooks = github.repos.hooks
            hook = repo_hooks.create(username, repo, github_settings)
          rescue => ex
            fail 'Hook creation in Github failed', exception: ex
          end
          info "Created hook with id '#{hook.id}'"
        end
      end

      stop do |params|
        api_key        = params['api_key']
        username       = params['username']
        repo           = params['repo']
        branch         = params['branch']

        if repo
          username, repo = repo.split('/') if repo.include?('/') && !username
          repo, branch   = repo.split('#') if repo.include?('#') && !branch
          branch         ||= 'master'
        end

        fail 'API Key is required' unless api_key
        fail 'Username is required' unless username
        fail 'Repo is required' unless repo

        hook_url = get_web_hook('post_receive')

        info 'Connecting to Github'
        begin
          github = Github.new oauth_token: api_key
        rescue
          fail 'Connection failed. Try re-activating Github in the sevices page.'
        end

        info 'Pulling up the hook info from Github'
        begin
          hooks = github.repos.hooks.list(username, repo)
          hook = hooks.find do |h|
            h['config'] && h['config']['url'] && h['config']['url'] == hook_url
          end
        rescue
          fail 'Getting info about the hook from Github failed'
        end

        fail "Hook wasn't found." unless hook

        info 'Deleting hook'
        begin
          github.repos.hooks.delete username, repo, hook.id
        rescue
          fail 'Deleting hook failed'
        end
      end
    end
  end

  action 'download' do |params|
    api_key        = params['api_key']
    username       = params['username']
    repo           = params['repo']
    branch         = params['branch']

    if repo
      username, repo = repo.split('/') if repo.include?('/') && !username
      repo, branch   = repo.split('#') if repo.include?('#') && !branch
      branch         ||= 'master'
    end

    fail 'Repo must be defined' unless repo
    fail 'API Key must be defined' unless api_key
    fail 'Username must be define' unless username

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Failed to connect to github. Try re-activating Github service.'
    end

    info 'Getting the Archive URL of the repo'
    begin
      repo_reference = {
        user: username,
        repo: repo
      }
      github_repo = github.repos.get(repo_reference)
      archive_url_template = github_repo.archive_url
      uri_string = archive_url_template
        .sub('{archive_format}', 'zipball')
        .sub('{/ref}', "/#{branch}")
      download_ref_uri = URI(uri_string)
    rescue => ex
      fail 'Failed to get archive URL from Github', exception: ex
    end

    info 'Downloading the repo from Github'
    begin
      client         = Net::HTTP.new(
        download_ref_uri.host,
        download_ref_uri.port)
      client.use_ssl = true
      access_query   = "access_token=#{api_key}"
      response       = client.get("#{download_ref_uri.path}?#{access_query}")
      uri_connector  = response['location'].include?('?') ? '&' : '?'
      response_data  = {
        content: "#{response['location']}#{uri_connector}#{access_query}"
      }
    rescue => ex
      fail 'Failed to download the repo from Github', exception: ex
    end

    action_callback response_data
  end
end
