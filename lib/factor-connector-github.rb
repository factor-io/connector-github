require 'github_api'
require 'factor/connector/definition'
require 'websockethook'

class GithubConnectorDefinition < Factor::Connector::Definition
  id :github

  def load_and_validate(params,key,requirements={})
    value = params[key]
    name = key.to_s.split('_').map{|e| e.capitalize}.join(' ')

    if requirements[:required]
      fail "#{name} (:#{key.to_s}) is required" unless value
    end

    if requirements[:default]
      value ||= requirements[:default]
    end

    if requirements[:is_a]
      fail "#{name} (:#{key.to_s}) must be a #{requirements[:is_a]}" unless value.is_a?(requirements[:is_a])
    end

    if requirements[:one_of]
      one_of = requirements[:one_of]
      raise "One Of (:one_of) must be an Array" unless one_of.is_a?(Array)
      
      options = "#{one_of[0..-2].join(', ')} or #{one_of[-1]}"
      fail "#{name} (:#{key.to_s}) must be #{options}" unless one_of.include?(value)
    end

    value
  end

  def init_github(params)
    api_key = load_and_validate(params,:api_key, required:true)
    github  = nil

    info 'Connecting to Github'
    begin
      github = Github.new oauth_token: api_key
    rescue
      fail 'Unable to connect to Github'
    end
    github
  end

  def parse_repo(params)
    original = load_and_validate(params,:repo, required:true)

    begin 
      full, username, repo, full_branch, branch = /^([\w\-]+)\/([\w\-]*)(#([\w\-\.]+))?$/.match(original).to_a
    rescue
      fail 'Repo (:repo) must be formated as (username)\(repo)#(branch), branch is optional'
    end

    fail 'Username in :repo must be defined' unless username
    fail 'Repository in :repo must be defined' unless repo

    branch ||= 'master'

    [username, repo, branch]
  end

  def wrap_call(entity, action, &block)

    terms = {
      close:    ['close', 'closing', 'closed'],
      create:   ['create', 'creating', 'created'],
      delete:   ['delete', 'deleting', 'deleted'],
      download: ['download','downloading', 'downloaded'],
      edit:     ['edit', 'editing', 'edited'],
      find:     ['find','finding', 'found'],
      get:      ['get','getting', 'retrieved'],
      list:     ['list', 'listing', 'retrieved'],
      update:   ['update', 'updating', 'updated'],
    }
    run, running, ran = terms[action]

    raise "Action (#{action}) is undefined" unless run && running && ran

    info "#{running.capitalize} the #{entity.downcase}"
    begin
      block.call
    rescue => ex
      fail "Unable to #{run} the #{entity.downcase}: #{ex.message}"
    end
    info "#{entity.capitalize} has been #{ran}"
  end

  resource :deployment do
    action :list do |params|
      github              = init_github(params)
      username, repo, ref = parse_repo(params)
      deployments         = nil

      wrap_call 'deployments', :list do
        deployments = github.repos.deployments.list(username, repo).body.map { |i| i.to_hash }
      end

      respond deployments
    end

    action :create do |params|
      github              = init_github(params)
      username, repo, ref = parse_repo(params)
      status              = nil
      tag_options         = %w(task auto_merge required_contexts payload environment description force)

      fail "Branch is required in the repo" unless ref

      deployment_params = {ref: ref} 
      params.each do |key,value|
        deployment_params[key.to_sym] = value if tag_options.include?(key.to_s)
      end

      wrap_call 'deployment', :create do
        status = github.repos.deployments.create(username, repo, deployment_params).body.to_hash
      end

      respond status
    end

    action :statuses do |params|
      github              = init_github(params)
      username, repo, ref = parse_repo(params)
      deployment          = load_and_validate(params,:deployment, required:true)
      deployment_statuses = nil

      wrap_call 'statuses', :get do
        deployment_statuses = github.repos.deployments.statuses(username, repo, deployment).body.map { |i| i.to_hash }
      end
      
      respond deployment_statuses
    end

    action :create_status do |params|
      github              = init_github(params)
      username, repo, ref = parse_repo(params)
      deployment          = load_and_validate(params,:deployment, required:true)
      state               = load_and_validate(params, :state, one_of:['pending','success','error','failure'])
      tag_options         = %w(target_url description)
      status              = nil

      status_params = {state: state, id: deployment} 
      params.each do |key,value|
        status_params[key.to_sym] = value if tag_options.include?(key.to_s)
      end

      wrap_call 'status', :create do
        status = github.repos.deployments.create_status(username, repo, deployment, status_params).body.to_hash
      end

      respond status
    end
  end

  resource :issue do
    action :list do |params|
      github = init_github(params)
      issues = nil

      keys = %w{user repo filter state since labels sort direction}
      payload = params.select{|k,v| keys.include?(k.to_s)}

      wrap_call 'issues', :list do
        issues = github.issues.list(payload).body.map { |i| i.to_hash }
      end

      respond issues
    end

    action :create do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      title                  = load_and_validate(params, :title, required:true)
      issue                  = nil

      payload = {
        user: username,
        repo: repo,
        title: title,
      }

      [:body, :assignee, :labels].each {|k| payload[k] = params[k] if params[k] }

      wrap_call 'issue', :create do
        issue = github.issues.create(payload).to_hash
      end

      respond issue
    end

    action :edit do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      number                 = load_and_validate(params, :number, required:true)
      issue                  = nil

      payload = {
        user: username,
        repo: repo
      }

      [:body, :assignee, :labels, :state, :title].each {|k| payload[k] = params[k] if params[k] }

      wrap_call 'issue', :edit do
        issue = github.issues.edit(username, repo, number, payload).to_hash
      end

      respond issue
    end
    
    action :get do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      number                 = load_and_validate(params, :number, required:true)
      issue = nil

      payload = {
        user:   username,
        repo:   repo,
        number: number
      }

      wrap_call 'issue', :get do
        issue = github.issues.get(payload).to_hash
      end

      respond issue
    end

    action :close do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      number                 = load_and_validate(params, :number, required:true)
      issue                  = nil

      wrap_call 'issue', :close do
        issue = github.issues.edit(username, repo, number, state: 'closed').to_hash
      end

      respond issue
    end
  end

  resource :release do
    action :list do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      releases               = nil

      wrap_call 'releases', :list do
        releases = github.repos.releases.list(username, repo).body.map { |i| i.to_hash }
      end

      respond releases
    end

    action :create do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      tag                    = load_and_validate(params, :tag, required:true)
      release                = nil

      tag_options = %w(target_commitish body name draft prerelease)

      tag_params = {} 
      params.each do |key,value|
        tag_params[key.to_sym] = value if tag_options.include?(key)
      end

      wrap_call 'releases', :create do
        release = github.repos.releases.create(username, repo, tag_name, tag_params).body.to_hash
      end

      respond release
    end

    action :get do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      id                     = load_and_validate(params, :id, required:true)
      release                = nil

      wrap_call 'releases', :get do
        release = github.repos.releases.get(username, repo, id).body.to_hash
      end

      respond release
    end

    action :delete do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      id                     = load_and_validate(params, :id, required:true)
      release                = nil

      wrap_call 'release', :delete do
        release = github.repos.releases.delete(username, repo, id).body.to_hash
      end

      respond release
    end
  end

  resource :repo do

    def download_archieve(github,api_key, username, repo, branch, archive_format)
      github_repo = nil
      download_ref_uri = nil
      response_data = nil

      wrap_call 'repository', :get do
        github_repo = github.repos.get(user: username, repo: repo)
      end

      wrap_call 'archive', :get do
        archive_url_template = github_repo.archive_url
        uri_string           = archive_url_template.sub('{archive_format}', archive_format).sub('{/ref}', "/#{branch}")
        download_ref_uri     = URI(uri_string)
      end

      wrap_call 'archive', :download do
        client         = Net::HTTP.new(download_ref_uri.host, download_ref_uri.port)
        client.use_ssl = true
        access_query   = "access_token=#{api_key}"
        response       = client.get("#{download_ref_uri.path}?#{access_query}")
        uri_connector  = response['location'].include?('?') ? '&' : '?'
        response_data  = { content: "#{response['location']}#{uri_connector}#{access_query}"}
      end

      response_data
    end

    action :download do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      archive_format         = load_and_validate(params,:archive_format, default:'tarball')

      download = download_archieve(github,params[:api_key], username, repo, branch, archive_format)

      respond download
    end

    events = [ 'commit_comment', 'create', 'delete', 'deployment', 'deployment_status',
      'download', 'fork', 'gollum', 'issue_comment', 'issues', 'member', 'page_build', 'public',
      'pull_request', 'pull_request_review_comment', 'push', 'release', 'team_add', 'watch']

      events.each do |event|

        listener event.to_sym do
          hook_thread = nil
          hook          = WebSocketHook.new

          start do |params|
            github                 = init_github(params)
            username, repo, branch = parse_repo(params)
            archive_format         = load_and_validate(params,:archive_format, default:'tarball')

            branch_path = branch ? "-#{branch}" : ''
            hook.register("github-#{username}-#{repo}#{branch_path}")

            hook_thread = Thread.new do
              hook.listen do |post|
                case post[:type]
                when 'registered'
                  hook_url = post[:data][:url]

                  hook = nil
                  wrap_call 'hooks', :find do
                    hook = github.repos.hooks.list(username, repo).find do |h|
                      h['config'] && h['config']['url'] && h['config']['url'] == hook_url
                    end
                  end

                  unless hook
                    wrap_call 'hook', :create do
                      github_settings = {
                        name: 'web',
                        active: true,
                        config: {url: hook_url, content_type: 'json'},
                        events: event
                      }
                      repo_hooks = github.repos.hooks
                      hook = repo_hooks.create(username, repo, github_settings).to_hash
                    end
                  end

                  respond hook
                when 'open', 'restart'
                  info "Hook status: #{post[:type]}"
                when 'close', 'error'
                  error "Hook status: #{post[:type]}"
                when 'hook'
                  info "Received a web hook"
                  hook_data = post[:data]
                  hook_branch = hook_data[:ref].split('/')[-1] if hook_data[:ref]

                  if hook_data[:zen]
                    info "Received ping for hook '#{hook_data['hook_id']}'."
                    warn 'Not triggering a workflow since this is not a push.'
                  elsif hook_branch != branch && event == :push
                    warn 'Incorrect branch on hook'
                    warn "expected: '#{branch}', got: '#{hook_branch}'"
                  else
                    download = download_archieve(github, params[:api_key], username, repo, branch, archive_format)
                    trigger download
                  end
                else
                  warn "Hook state unknown: #{post[:type]}"
                end
              end
            end
          end

          stop do
            hook.stop
            begin
              hook_thread.kill
            rescue
            end
          end
        end
      end

  end

  resource :status do
    action :list do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      statuses               = nil
      
      fail "You must specify branch/ref in the Repository (:repo) parameter" unless branch

      wrap_call 'statuses', :list do
        statuses = github.repos.statuses.list(username, repo, branch).body.each { |i| i.to_hash }
      end

      respond statuses
    end

    action :create do |params|
      github                 = init_github(params)
      username, repo, branch = parse_repo(params)
      state                  = load_and_validate(params,:state,required:true,one_of:['pending','success','error','failure'])
      sha                    = load_and_validate(params,:sha,required:true)
      status                 = nil

      tag_options = %w(target_url description context)

      status_params = {state: state, sha: sha} 
      params.each do |key,value|
        status_params[key.to_sym] = value if tag_options.include?(key)
      end

      wrap_call 'status', :create do
        status = github.repos.statuses.create(username, repo, sha, status_params).to_hash
      end

      respond status
    end
  end
end