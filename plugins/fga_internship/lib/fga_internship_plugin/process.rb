class FgaInternshipPlugin::Process < ActiveRecord::Base
  
	has_many :checklists

	belongs_to :community_id, class_name: "Profile", foreign_key: "community_id"
	belongs_to :student_id, class_name: "Profile",  foreign_key: "student_id"
	belongs_to :supervisor_id, class_name: "Profile",  foreign_key: "supervisor_id"

end
