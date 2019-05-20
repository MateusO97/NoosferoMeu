class CreateTaskLists < ActiveRecord::Migration[5.0]
  def self.up
   create_table :fga_internship_plugin_task_lists do |t|
      t.column :name,              :string
      t.column :link,   					 :string

      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
  	drop_table :fga_internship_plugin_task_lists
  end
end
