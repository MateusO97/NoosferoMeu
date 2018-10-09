class FgaInternshipPlugin < Noosfero::Plugin

  def self.plugin_name
    "Fga Internship"
  end

  def self.plugin_description
    _("A plugin that does this and that.")
  end

  def self.extra_blocks
    {
      InternshipBlock => {:type => Community}
    }
  end

  def stylesheet?
    true
  end

end
