class FgaInternshipPlugin::Document < ActiveRecord::Base
  
	has_one :checklist

	attr_accessible :name, :doc_type, :view_permission, :write_permission, :phase

end
