class AddRoleToInternshipCoordinator < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        Role.create!(
          name: 'Internship Coordinator',
          key: 'profile_internship_coordinator',
          permissions: ['manage_internship'],
          environment: Environment.default
        )
      end
      dir.down do
        Role.find_by(name: 'Internship Coordinator').destroy!
      end
    end
  end
end
