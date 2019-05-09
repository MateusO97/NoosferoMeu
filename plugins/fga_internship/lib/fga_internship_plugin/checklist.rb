class FgaInternshipPlugin::Checklist < ActiveRecord::Base

	belongs_to :document
	belongs_to :internship_process
	
  attr_accessible :name, :link, :checked

end
