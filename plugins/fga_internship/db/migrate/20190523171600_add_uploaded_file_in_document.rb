class AddUploadedFileInDocument < ActiveRecord::Migration[5.1]
    def self.up
     add_reference :fga_internship_plugin_documents, :uploaded_file, index: { unique: true }
    end
    
    def self.down
        remove_reference :fga_internship_plugin_documents, :uploaded_file, index: true
    end
  end
  