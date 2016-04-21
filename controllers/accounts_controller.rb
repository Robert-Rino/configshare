# Sinatra Application Controllers
class ShareConfigurationsAPI < Sinatra::Base
  get '/api/v1/accounts/:username' do
    content_type 'application/json'

    username = params[:username]
    account = Account.where(username: username).first

    if account
      projects = account.owned_projects
      JSON.pretty_generate(data: account, relationships: projects)
    else
      halt 404, "PROJECT NOT FOUND: #{username}"
    end
  end

  post '/api/v1/accounts/?' do
    begin
      data = JSON.parse(request.body.read)
      new_account = CreateNewAccount.call(
        username: data['username'],
        email: data['email'],
        password: data['password'])
    rescue => e
      logger.info "FAILED to create new account: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', new_account.username).to_s

    status 201
    headers('Location' => new_location)
  end

  post '/api/v1/accounts/:username/projects/?' do
    begin
      username = params[:username]
      new_data = JSON.parse(request.body.read)

      account = Account.where(username: username).first
      saved_project = account.add_owned_project(name: new_data['name'])
      saved_project.repo_url = new_data['repo_url'] if new_data['repo_url']
      saved_project.save
    rescue => e
      logger.info "FAILED to create new project: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', saved_project.id.to_s).to_s

    status 201
    headers('Location' => new_location)
  end

  get '/api/v1/accounts/:username/projects/?' do
    content_type 'application/json'

    begin
      username = params[:username]
      account = Account.where(username: username).first

      my_projects = Project.where(owner_id: account.id).all
      other_projects = Project.join(:accounts_projects, project_id: :id)
                              .where(contributor_id: account.id).all

      all_projects = my_projects + other_projects
      JSON.pretty_generate(data: all_projects)
    rescue => e
      logger.info "FAILED to get projects for #{username}: #{e}"
      halt 404
    end
  end
end