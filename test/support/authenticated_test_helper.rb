module AuthenticatedTestHelper

  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    # FIXME rails 5 not allow put values on controller session like this anymore 
    # To make the loggin we have to access the post action of account controller
    # Tests inherited form ActionDispatch::IntegrationTest have to make the post request
    if @controller && @request
      @request.session[:user] = User.find_by(login: user.to_s).id 
    else 
      old_controller = @controller
      @controller = AccountController.new

      post login_account_index_path, params: { user: { login: user, password: '123456'} }
      @controller = old_controller
    end
  end

  def logout
    #FIXME refactor this method
    if false
	    puts '1111111111111111111111111111111111111111111111111111111'
	    raise @controller.inspect
      @request.session.delete(:user) if @request
    else 
      old_controller = @controller
      @controller = AccountController.new

      get logout_account_index_path
      @controller = old_controller
    end
  end

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env["HTTP_ACCEPT"] = accept
  end

  def authorize_as(user)
    if user
      @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64("#{users(user).login}:test")}"
      accept       'application/xml'
      content_type 'application/xml'
    else
      @request.env["HTTP_AUTHORIZATION"] = nil
      accept       nil
      content_type nil
    end
  end

  # Assert the block redirects to the login
  #
  #   assert_requires_login(:bob) { |c| c.get :edit, :id => 1 }
  #
  def assert_requires_login(login = nil)
    yield HttpLoginProxy.new(self, login)
  end

  def assert_http_authentication_required(login = nil)
    yield XmlLoginProxy.new(self, login)
  end

  def reset!(*instance_vars)
    instance_vars = [:controller, :request, :response] unless instance_vars.any?
    instance_vars.collect! { |v| "@#{v}".to_sym }
    instance_vars.each do |var|
      instance_variable_set(var, instance_variable_get(var).class.new)
    end
  end
end

class BaseLoginProxy
  attr_reader :controller
  attr_reader :options
  def initialize(controller, login)
    @controller = controller
    @login      = login
  end

  private
    def authenticated
      raise NotImplementedError
    end

    def check
      raise NotImplementedError
    end

    def method_missing(method, *args)
      @controller.reset!
      authenticate
      @controller.send(method, *args)
      check
    end
end

class HttpLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.login_as @login if @login
    end

    def check
      @controller.assert_redirected_to :controller => 'account', :action => 'login'
    end
end

class XmlLoginProxy < BaseLoginProxy
  protected
    def authenticate
      @controller.accept 'application/xml'
      @controller.authorize_as @login if @login
    end

    def check
      @controller.assert_response 401
    end
end
