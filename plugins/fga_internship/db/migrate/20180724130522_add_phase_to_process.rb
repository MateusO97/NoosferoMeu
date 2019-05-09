class AddPhaseToProcess < ActiveRecord::Migration[5.0]
	def self.up
		add_column :fga_internship_plugin_processes, :phase, :string, :default => 'pre-application'
	end

	def self.down
		remove_column :fga_internship_plugin_processes, :phase
	end
end
