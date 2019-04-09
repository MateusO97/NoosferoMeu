class InternshipBlock < Block

  settings_items :community_id, :type => :integer, :default => nil

  def self.plugin_description
    _('Internship')
  end

  def help
    _('This block gives access to internships processes')
  end

  def view_title
    _('Internship')
  end


end
