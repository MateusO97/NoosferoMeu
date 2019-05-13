class AddRoleToInternshipCoordinator < ActiveRecord::Migration[5.1]
  def change
    Role.create!(
      name: 'Internship Coordinator',
      key: 'internship_coordinator',
      permissions: ['manage_internship'],
      environment: Environment.default
    )
  end
end
