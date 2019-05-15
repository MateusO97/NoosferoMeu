class AddRoleToProfile < ActiveRecord::Migration[5.1]
  def self.up
    add_column :profiles, :internship_role, :string, :default => 'none'
  end

  def self.down
    remove_column :profiles, :internship_role
  end
end
