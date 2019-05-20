class CreateDocuments < ActiveRecord::Migration[5.0]
  def self.up
   create_table :fga_internship_plugin_documents do |t|
      t.column :name,              :string
      t.column :doc_type,					 :string
  		t.column :view_permission,   :string, :array => true, :default => []
  		t.column :write_permission,  :string, :array => true, :default => []
      t.column :phase,             :string

      t.column :created_at,        :datetime
    end
  end

  def self.down
  	drop_table :fga_internship_plugin_documents
  end
end
