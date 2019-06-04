require_dependency 'profile'

class Profile
	attr_accessible :internship_role

	has_one :community, foreign_key: "community_id"
	has_one :student, foreign_key: "student_id"
	has_one :supervisor, foreign_key: "supervisor_id"

  def registration

  end  

end
