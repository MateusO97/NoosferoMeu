require_dependency 'user'

class User
  before_create do |user|
    if user.environment.nil?
      user.environment = Environment.default
    end
    unless user.is_temporary?
      user.send(:make_activation_codes) unless user.environment.enabled?('skip_new_user_email_confirmation')
    end
  end

  after_create do |user|
    unless user.person
      p = Person.new

      p.attributes = user.person_data
      p.identifier = user.login if p.identifier.blank?
      p.user = user
      p.environment = user.environment
      p.name ||= user.name || user.login
      p.visible = false unless user.activated?
      p.save!

      user.person = p
    end
    if user.environment.enabled?('skip_new_user_email_confirmation')
      if user.environment.enabled?('admin_must_approve_new_users')
        create_moderate_task
      else
        user.activate!
      end
    elsif user.is_temporary?
      user.activate!
    end
  end
end
