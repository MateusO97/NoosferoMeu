class CreateProcesses < ActiveRecord::Migration[5.0]
  def self.up
  	create_table :fga_internship_plugin_processes do |t|
      t.column :created_at,        :datetime
    end

  	add_reference :fga_internship_plugin_processes, :community, index: true
  	add_reference :fga_internship_plugin_processes, :supervisor, index: true
    add_reference :fga_internship_plugin_processes, :student, index: { unique: true }
  end

  def self.down
  	drop_table :fga_internship_plugin_processes
  end
end
