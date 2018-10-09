class AddDocumentToChecklist < ActiveRecord::Migration
  def self.up
   add_reference :fga_internship_plugin_checklists, :document, index: { unique: true }
  end

  def self.down
  	remove_reference :fga_internship_plugin_checklists, :document, index: true
  end
end