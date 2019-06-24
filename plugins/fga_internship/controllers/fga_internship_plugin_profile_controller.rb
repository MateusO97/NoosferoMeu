class FgaInternshipPluginProfileController < ProfileController
  require 'securerandom'
  require 'exceptions'

  include FgaInternshipPlugin::ProcessCreator
  include CustomFormsPlugin::Helper

  before_action :is_logged_in?, :only => [:index_pre_enrolled_students,
    :index_pre_enrolled_students_filter_by_date, :index]
  before_action :get_internship_process, :only => [:internship_pre_application,
    :internship_application, :internship_in_progress, :internship_evaluation]
  before_action :has_manage_internship_permission?, :only => [:index_pre_enrolled_students,
    :index_pre_enrolled_students_filter_by_date]

  no_design_blocks

  INTERNSHIP_FORM_IDENTIFIER = 'estágio'
  ACTIVE_PROCESSES_NAME = 'processos ativos'
  INACTIVE_PROCESSES_NAME = 'processos inativos'


  # Search pre enrolled students throght date range and render then as json
  # url: POST /profile/ <community name> /plugin/fga_internship/list_pre_enrolle
  # d_students_filter_by_date/
  def index_pre_enrolled_students_filter_by_date

    if validate_all_params_presence([params[:min_date], params[:max_date]])

      form = CustomFormsPlugin::Form.find_by(identifier: INTERNSHIP_FORM_IDENTIFIER)
      submissions = CustomFormsPlugin::Submission.where form_id: form.id

      min_date = Date.parse(params[:min_date])
      max_date = Date.parse(params[:max_date])

      submissions_filtered_by_date = submissions.where(:created_at => min_date..max_date)

      new_submissions = []

      submissions_filtered_by_date.each do |submission|

        name = submission.profile.name
        email = submission.profile.email
        date = submission.created_at.strftime("%d-%m-%Y").gsub!('-','/')
        time = submission.created_at.strftime("%H:%m")

        new_submissions.push({name: name, email: email, date: date, time: time})
      end

      render json: new_submissions
    else
      session[:notice] = _("Params min_date and max_date are required")
      redirect_to root_path
    end

  end

  def index_pre_enrolled_students
      form = CustomFormsPlugin::Form.find_by(identifier: INTERNSHIP_FORM_IDENTIFIER)
      @submissions = CustomFormsPlugin::Submission.where form_id: form.id
  end

  def index
    @community_id = params[:community_id]
    unless Folder.find_by(:name => ACTIVE_PROCESSES_NAME, :profile_id => @community_id)
      active_processes = Folder.new
      active_processes.name = ACTIVE_PROCESSES_NAME
      active_processes.profile_id = @community_id
      active_processes.save
    end
    unless Folder.find_by(:name => INACTIVE_PROCESSES_NAME, :profile_id => @community_id)
      inactive_processes = Folder.new
      inactive_processes.name = INACTIVE_PROCESSES_NAME
      inactive_processes.profile_id = @community_id
      inactive_processes.save
    end
  end

  def internship_pre_application
    @checklists = []
    @process.checklists.each do |checklist|
      if(checklist.document.phase == "pre-application")
        @checklists << checklist
      end
    end

    community = @process.community_id
    active_processes = Folder.find_by(:name => ACTIVE_PROCESSES_NAME, :profile_id => community.id)

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
    @process.checklists.each do |checklist|
      if(checklist.document.phase == "application")
        @checklists << checklist
      end
    end
  end

  def internship_in_progress
    @checklists = []
    @process.checklists.each do |checklist|
      if(checklist.document.phase == "in-progress")
        @checklists << checklist
      end
    end
  end

  def internship_evaluation
    @checklists = []
    @process.checklists.each do |checklist|
      if(checklist.document.phase == "evaluation")
        @checklists << checklist
      end
    end
  end

  def show_forms
    update_checklist
    redirect_to :controller => :fga_internship_plugin_profile,
      :action => :internship_pre_application,
      :checklist_id => params[:checklist_id],
      :fga_internship_plugin_checklists => {checked: true}
  end

  def answer_form
    @form = CustomFormsPlugin::Form.find_by(identifier: INTERNSHIP_FORM_IDENTIFIER)
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
        redirect_to :controller => :fga_internship_plugin_profile,
          :action => :internship_pre_application,
          :checklist_id => params[:checklist_id],
          :fga_internship_plugin_checklists => { checked: true }
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

  def is_logged_in?
    if current_user
      # Do nothing
    else
      session[:notice] = _("You need to sign in")
      redirect_to({ :controller => "account" ,:action => "login" })
    end
  end

  def has_manage_internship_permission?
    if current_person.has_permission?('manage_internship', profile)
      # Do nothing
    else
      session[:notice] = _("You need manage internship permission to acess")
      redirect_to user
    end
  end

  def validate_all_params_presence(param_list)
    param_list.each do |param|
      if param
        # Do nothing
      else
        return false
      end
    end
    return true
  end

  private

  def get_internship_process
    @process = FgaInternshipPlugin::InternshipProcess.where(student_id: current_person.id).first
    if @process.nil?
      @process = create_process
    end
    return @process
  end

  def checklist_params
    params.require(:fga_internship_plugin_checklists).permit(:checked)
  end

end
