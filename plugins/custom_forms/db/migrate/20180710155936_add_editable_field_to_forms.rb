class AddEditableFieldToForms < ActiveRecord::Migration
  def self.up
    def change
      add_column :custom_forms_plugin_forms, :is_editable, :boolean, default: false
    end
  end
  def self.down
    def change
      remove_column :custom_forms_plugin_forms, :is_editable
    end
  end
end
