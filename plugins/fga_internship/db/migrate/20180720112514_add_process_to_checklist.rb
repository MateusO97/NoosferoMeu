class AddProcessToChecklist < ActiveRecord::Migration[5.0]
  def self.up
  	add_reference :fga_internship_plugin_checklists, :internship_process, index: true
  end

  def self.down
  	remove_reference :fga_internship_plugin_checklists, :internship_process, index: true
  end
end
