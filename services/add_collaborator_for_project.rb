# Add a collaborator to another owner's existing project
class AddCollaboratorForProject
  def self.call(collaborator_id:, project_id:)
    collaborator = BaseAccount.where(id: collaborator_id.to_i).first
    project = Project.first(id: project_id.to_i)
    if project.owner.id != collaborator.id
      collaborator.add_project(project)
      collaborator
    else
      false
    end
  end
end
