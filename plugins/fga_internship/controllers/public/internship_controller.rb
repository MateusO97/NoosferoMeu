class InternshipController < PublicController
  require 'securerandom'
  require 'exceptions'

  include FgaInternshipPlugin::ProcessCreator
  include CustomFormsPlugin::Helper

  before_action :get_profile
  before_action :has_access, :only => [:show]
  before_action :get_internship_process, :only => [:internship_pre_application,
    :internship_application, :internship_in_progress, :internship_evaluation]

  no_design_blocks


  def pre_enrolled_students_filter_date

    min_date = Date.parse(params[:min_date])
    max_date = Date.parse(params[:max_date])

    internship_form_identifier = 'estágio'

    form = CustomFormsPlugin::Form.find_by(identifier: internship_form_identifier)
    submissions = CustomFormsPlugin::Submission.where form_id: form.id

    new_submissions = []

    submissions.each do |submission|

      if submission.created_at >= min_date && submission.created_at <= max_date

        name = submission.profile.name
        email = submission.profile.email
        date = submission.created_at.strftime("%d-%m-%Y").gsub!('-','/')
        time = submission.created_at.strftime("%H:%m")

        new_submissions.push({name: name, email: email, date: date, time: time})
      end
    end

    render json: new_submissions

  end

  def index_pre_enrolled_students
    if !current_user
      session[:notice] = _("You need to sign in")
      redirect_to root_path
    else
      if current_person.has_permission?('manage_internship', profile)

        internship_form_identifier = 'estágio'

        form = CustomFormsPlugin::Form.find_by(identifier: internship_form_identifier)
        @submissions = CustomFormsPlugin::Submission.where form_id: form.id

      else
        redirect_to user
      end
    end
  end

  def index
    @community_id = params[:community_id]
    unless Folder.find_by(:name => 'processos ativos', :profile_id => @community_id)
      active_processes = Folder.new
      active_processes.name = 'processos ativos'
      active_processes.profile_id = @community_id
      active_processes.save
    end
    unless Folder.find_by(:name => 'processos inativos', :profile_id => @community_id)
      inactive_processes = Folder.new
      inactive_processes.name = 'processos inativos'
      inactive_processes.profile_id = @community_id
      inactive_processes.save
    end
  end

  def internship_pre_application
    @checklists = []
    @process.checklists.order(:id).each do |checklist|
      if(checklist.document.phase == "pre-application")
        @checklists << checklist
      end
    end

    community = @process.community_id
    active_processes = Folder.find_by(:name => 'processos ativos', :profile_id => community.id)

    unless Folder.find_by(:name => self.current_user.name , :profile_id => community.id, :parent_id =>active_processes.id)
      user_folder = Folder.new
      user_folder.name = self.current_user.name
      user_folder.profile_id = community.id
      user_folder.parent_id = active_processes.id
      user_folder.save
    end
  end

  # call here the creation of supervisor's tmp user
  # call the mailers and send email to supervisor with his login and password
  def internship_application
    @checklists = []
    @process.checklists.order(:id).each do |checklist|
      if(checklist.document.phase == "application")
        @checklists << checklist
      end
    end
  end

  def internship_in_progress
    @checklists = []
    @process.checklists.order(:id).each do |checklist|
      if(checklist.document.phase == "in-progress")
        @checklists << checklist
      end
    end
  end

  def internship_evaluation
    @checklists = []
    @process.checklists.order(:id).each do |checklist|
      if(checklist.document.phase == "evaluation")
        @checklists << checklist
      end
    end
  end

  def login
    store_location(request.referer) unless params[:return_to] or session[:return_to]

    return unless request.post?

    begin
      self.current_user ||= User.authenticate(params[:user][:login], params[:user][:password], environment) if params[:user]
    rescue User::UserNotActivated => e
      session[:notice] = e.message
      return
    end
    if logged_in?
      check_join_in_community(self.current_user)

      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = {value: self.current_user.remember_token, expires: self.current_user.remember_token_expires_at}
      end

      session[:notice] = _("Logged in successfully")
    else
      session[:notice] = _('Incorrect username or password')
    end

    redirect_to :controller => :internship , :action => :index, :community_id => params[:community_id]
  end

  def show_forms
    update_checklist
    redirect_to :controller => :internship, :action => :internship_pre_application, :checklist_id => params[:checklist_id], :fga_internship_plugin_checklists => {checked: true}
  end

  def answer_form
    internship_form_identifier = 'estágio'
    @form = CustomFormsPlugin::Form.find_by(identifier: internship_form_identifier)
    @community = Community.find_by(id: params[:community_id])

    if user
      @submission = CustomFormsPlugin::Submission.find_by form_id: @form.id, profile_id: user.id
      @submission ||= CustomFormsPlugin::Submission.new(:form => @form, :profile => user)
    else
      @submission = CustomFormsPlugin::Submission.new(:form => @form)
    end

    # update_checklist

    # build the answers
    @answers = if params[:submission] then @submission.build_answers params[:submission] else @submission.answers end

    if request.post?
      begin
        raise SubmissionError, 'Form expired!' if @form.expired?

        if !user
          @submission.author_name = params[:author_name]
          @submission.author_email = params[:author_email]
        end

        unless @submission.save
          raise SubmissionError, 'Submission failed: answers not valid'
        end

        session[:notice] = _('Submission saved')
        redirect_to :controller => :internship, :action => :internship_pre_application, :checklist_id => params[:checklist_id], :fga_internship_plugin_checklists => {checked: true}
      rescue SubmissionError => err
        session[:notice] = _(err.message)
      end
    end
  end

  def update_checklist
    checklist = FgaInternshipPlugin::Checklist.find(params[:checklist_id])
    checklist.update(checklist_params)
    checklist.save
  end

  def check_join_in_community(user)
    profile_to_join = session[:join]
    unless profile_to_join.blank?
     environment.profiles.find_by(identifier: profile_to_join).add_member(user.person)
     session.delete(:join)
    end
  end

  def archive_semester
    # at the end of the semester, save all data in a  specific folder and remove
    # all temporary users from the database
    tmp_users = User.find_by(is_temporary: true)
    tmp_users.each do |tu|
      tu.deactivate!
    end
  end

  private
  # creates a temporary user given his fields
  def create_temporary_user(email, name)
    password = generate_password
    temporary_user = User.create(
      login: generate_login(name),
      email: email,
      name: name,
      password: password,
      password_confirmation: password,
      is_temporary: true)
    temporary_user.save!
    UserMailer.temporary_user_credentials_email(temporary_user, password).deliver
  end

  # deletes all tmp users from db
  def delete_tmp_users
    tmp_users = User.find_by(is_temporary: true)
    tmp_users.each do |tmp|
      tmp.destroy!
    end
  end

  def req_fields
    ['supervisor_name','supervisor_email']
  end

  def generate_password
    SecureRandom.hex[10..20].reverse
  end

  def generate_login(name)
    name.split(' ').first.downcase + rand(100..999).to_s
  end

  def update_role
    @profile.update(profile_params)
    @profile.save
  end

  def get_internship_process
    @process = FgaInternshipPlugin::InternshipProcess.where(student_id: current_person.id).first
    if @process.nil?
      @process = create_process
    end
    return @process
  end

  def profile_params
    require(:profile).permit(:intenship_role)
  end

  def process_params
    params.require(:fga_internship_plugin_processes).permit(:phase)
  end

  def checklist_params
    params.require(:fga_internship_plugin_checklists).permit(:checked)
  end

  def get_profile
    @profile = current_user.person if current_user
  end

end
