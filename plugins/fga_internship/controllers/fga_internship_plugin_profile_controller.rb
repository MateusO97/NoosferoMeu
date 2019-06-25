class FgaInternshipPluginProfileController < ProfileController
  require "securerandom"
  require "exceptions"

  include FgaInternshipPlugin::ProcessCreator
  include CustomFormsPlugin::Helper

  before_action :redirect_if_is_not_logged_in,
                only: [:index_pre_enrolled_students,
                       :index_pre_enrolled_students_filter_by_date,
                       :index]
  before_action :has_manage_internship_permission?,
                only: [:index_pre_enrolled_students,
                       :index_pre_enrolled_students_filter_by_date]
  before_action :get_custom_forms_plugin_form_internship,
                only: [:index_pre_enrolled_students,
                       :index_pre_enrolled_students_filter_by_date,
                       :answer_form]

  no_design_blocks

  INTERNSHIP_FORM_IDENTIFIER = "estágio"
  ACTIVE_PROCESSES_NAME = "processos ativos"
  INACTIVE_PROCESSES_NAME = "processos inativos"

  # First instructions for the student to begin the internship process
  def internship_process_welcome
    @community_id = params[:community_id]
    unless Folder.find_by(name: ACTIVE_PROCESSES_NAME, profile_id: @community_id)
      active_processes = Folder.new
      active_processes.name = ACTIVE_PROCESSES_NAME
      active_processes.profile_id = @community_id
      active_processes.save
    end
    unless Folder.find_by(name: INACTIVE_PROCESSES_NAME, profile_id: @community_id)
      inactive_processes = Folder.new
      inactive_processes.name = INACTIVE_PROCESSES_NAME
      inactive_processes.profile_id = @community_id
      inactive_processes.save
    end
  end

  # Pre-registration in the internship process where the student completes the
  # pre-enrollment form
  def internship_process_pre_registration
    @checklists = get_checklists_by_phase("pre-application")

    community_id = @process.community_id
    active_processes = Folder.find_by(name: ACTIVE_PROCESSES_NAME, profile_id: community_id)

    unless Folder.find_by(name: self.current_user.name, profile_id: community_id, parent_id: active_processes)
      user_folder = Folder.new
      user_folder.name = self.current_user.name
      user_folder.profile_id = community_id
      user_folder.parent_id = active_processes
      user_folder.save
    end
  end

  # Registration in the internship process where the student provide:
  # Term of Commitment, Activities plan and School History
  def internship_process_registration
    @checklists = get_checklists_by_phase("application")
  end

  # Stage where the internship process is in progress and the student provide:
  # Technical report and Internship Plan + Guidance Counselor's Opinion
  def internship_process_in_progress
    @checklists = get_checklists_by_phase("in-progress")
  end

  # Evaluation stage of the internship process where the student provide:
  # Trainee Performance Assessment, Stage Evaluation Sheet and
  # Assessment of Internship and Grantor by Student
  def internship_process_evaluation
    @checklists = get_checklists_by_phase("evaluation")
  end

  # Search pre enrolled students throght date range and render then as json
  # url: POST /profile/ <community name> /plugin/fga_internship/list_pre_enrolle
  # d_students_filter_by_date/
  def index_pre_enrolled_students_filter_by_date
    if validate_all_params_presence([params[:min_date], params[:max_date]]) &&
       request.post?

      submissions = CustomFormsPlugin::Submission.where form_id: @form.id

      min_date = Date.parse(params[:min_date])
      max_date = Date.parse(params[:max_date])

      submissions_filtered_by_date = submissions.where(created_at: min_date..max_date)

      pre_enrolled_students = []

      submissions_filtered_by_date.each do |submission|
        name = submission.profile.name
        email = submission.profile.email
        date = submission.created_at.strftime("%d-%m-%Y").gsub!("-", "/")
        time = submission.created_at.strftime("%H:%m")

        pre_enrolled_students.push name: name, email: email, date: date, time: time
      end

      render json: pre_enrolled_students
    else
      session[:notice] = ("Params POST min_date and max_date are required")
      redirect_to root_path
    end
  end

  # Screen where internship coordinator can see all pre enrolled students
  def index_pre_enrolled_students
    @submissions = CustomFormsPlugin::Submission.where form_id: @form.id
  end

  def answer_form
    @community = Community.find_by(id: params[:community_id])

    if user
      @submission = CustomFormsPlugin::Submission.find_by(form_id: @form.id,
                                                          profile_id: user.id)
      @submission ||= CustomFormsPlugin::Submission.new(form: @form,
                                                        profile: user)
    else
      @submission = CustomFormsPlugin::Submission.new(form: @form)
    end

    # build the answers
    if params[:submission]
      @answers = @submission.build_answers params[:submission]
    else
      @answers = @submission.answers
    end

    if request.post?
      begin
        if @form.expired?
          raise SubmissionError, "Form expired!"
        end

        if !user
          @submission.author_name = params[:author_name]
          @submission.author_email = params[:author_email]
        end

        unless @submission.save
          raise SubmissionError, "Submission failed: answers not valid"
        end

        session[:notice] = _("Submission saved")
        redirect_to controller: :fga_internship_plugin_profile,
                    action: :internship_process_pre_registration,
                    checklist_id: params[:checklist_id],
                    fga_internship_plugin_checklists: { checked: true }
      rescue SubmissionError => error
        session[:notice] = _(error.message)
      end
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

  def redirect_if_is_not_logged_in
    if current_user
      # Do nothing
    else
      session[:notice] = _("You need to sign in")
      redirect_to controller: "account", action: "login"
    end
  end

  private

    def get_checklists_by_phase(phase)
      @process = FgaInternshipPlugin::InternshipProcess.where(student_id: current_person.id).first
      if @process.nil?
        @process = create_process
      end

      @process.checklists.select { |checklist| checklist.document.phase == phase }
    end

    def checklist_params
      params.require(:fga_internship_plugin_checklists).permit(:checked)
    end

    def get_custom_forms_plugin_form_internship
      @form = CustomFormsPlugin::Form.find_by(identifier: INTERNSHIP_FORM_IDENTIFIER)
    end

    def has_manage_internship_permission?
      if current_person.has_permission?("manage_internship", profile)
        # Do nothing
      else
        session[:notice] = _("You need manage internship permission to acess")
        redirect_to user
      end
    end
end
