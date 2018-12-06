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

  def self.load_custom_routes
    Noosfero::Application.routes.draw do
      match "/profile/:profile/internship_query/:id" => 'internship#answer_form',
        via: [:get, :post], as: 'internship_plugin_answer_form'
    end
  end

end
