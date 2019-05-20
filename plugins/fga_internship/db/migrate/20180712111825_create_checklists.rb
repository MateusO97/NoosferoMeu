class CreateChecklists < ActiveRecord::Migration[5.0]
  def self.up
   create_table :fga_internship_plugin_checklists do |t|
      t.column :name,              :string
      t.column :link,   					 :string
  		t.column :checked,           :boolean

      t.column :created_at,        :datetime
    end
  end

  def self.down
  	drop_table :fga_internship_plugin_checklists
  end
end
