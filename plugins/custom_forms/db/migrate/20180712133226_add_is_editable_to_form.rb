class AddIsEditableToForm < ActiveRecord::Migration
  def self.up
    add_column :custom_forms_plugin_forms, :is_editable, :boolean,
      :default => false
  end

  def self.down
    remove_column :custom_forms_plugin_forms, :is_editable
  end
end
