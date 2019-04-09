require_dependency 'user_mailer'

Rails.configuration.to_prepare do
  SearchMailer.send :include, UserMailer
end

class UserMailer
  def signup_welcome_email(user)
    self.environment = user.environment

    email_subject = user.environment.signup_welcome_text_subject

    unless user.is_temporary?
      puts '\/\/\/\/\/\/\/'*10
      puts 'funfou'
      puts '\/\/\/\/\/\/\/'*10
      @body = user.environment.signup_welcome_text_body.gsub('{user_name}', user.name)
    else
      @body = user.environment.signup_welcome_text_body.gsub('{user_name}', user.name)
    end
    mail(
      content_type: 'text/html',
      to: user.email,
      from: "#{user.environment.name} <#{user.environment.noreply_email}>".html_safe,
      subject: email_subject.blank? ? _("Welcome to environment %s").html_safe % [user.environment.name] : email_subject,
      body: @body
    )
  end

  def temporary_user_credentials_email user, password
    @user = user
    @psswrd = password
    mail(
      to: @user.email,
      from: "#{user.environment.name} <#{user.environment.noreply_email}>".html_safe,
      subject: "Your credentials for the %s".html_safe % [user.environment.name]
    )
  end
end
