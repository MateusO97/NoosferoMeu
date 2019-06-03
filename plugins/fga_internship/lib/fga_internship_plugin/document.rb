class FgaInternshipPlugin::Document < ActiveRecord::Base
  
	has_one :checklist
	belongs_to :uploaded_file
	attr_accessible :name, :doc_type, :view_permission, :write_permission, :phase

end
