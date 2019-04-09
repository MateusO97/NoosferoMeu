class FgaInternshipPlugin::Checklist < ActiveRecord::Base

	belongs_to :document
	belongs_to :process
	

  attr_accessible :name, :link, :checked

end
