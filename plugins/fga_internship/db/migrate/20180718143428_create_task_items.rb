class CreateTaskItems < ActiveRecord::Migration[5.0]
  def self.up
  # TODO: add reference to submission and file uploaded and task list
   create_table :fga_internship_plugin_task_items do |t|
      t.column :description, :text
  		t.column :status, :boolean, default: false
      t.column :file_path, :string, default: ''

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
  	drop_table :fga_internship_plugin_task_items
  end
end
