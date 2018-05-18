class ControlPanel::HeaderAndFooter < ControlPanel::Entry
  class << self
    def name
      _('Header and Footer')
    end

    def section
      'design'
    end

    def icon
      'object-group'
    end

    def priority
      20
    end

    def url(profile)
     {:controller => 'profile_editor', :action => 'header_footer'}
    end

    def display?(user, profile, context={})
      user.is_admin?(profile.environment) || (!profile.enterprise? && !profile.environment.enabled?('disable_header_and_footer'))
    end
  end
end

