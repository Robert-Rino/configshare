class ShareConfigurationsAPI < Sinatra::Base
  def authorized_affiliated_project(env, project_id)
    account = authenticated_account(env)
    all_projects = FindAllAccountProjects.call(id: account['id'])
    all_projects.select { |proj| proj.id == project_id.to_i }.first
  rescue
    nil
  end

  get '/api/v1/projects/:id' do
    content_type 'application/json'
    project = authorized_affiliated_project(env, params[:id])
    halt(401, 'Not authorized, or project might not exist') unless project
    project.to_full_json
  end

  post '/api/v1/projects/:project_id/collaborators/?' do
    content_type 'application/json'
    begin
      criteria = JSON.parse request.body.read
      collaborator = FindBaseAccountByEmail.call(criteria['email'])
      project = authorized_affiliated_project(env, params[:project_id])
      raise('Unauthorized or not found') unless project && collaborator

      collaborator = AddCollaboratorForProject.call(
        collaborator_id: collaborator.id,
        project_id: project.id)
      collaborator ? status(201) : raise('Could not add collaborator')
    rescue => e
      logger.info "FAILED to add collaborator to project: #{e.inspect}"
      halt 401
    end

    collaborator.to_json
  end
end
