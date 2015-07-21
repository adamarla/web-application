class TeachersController < ApplicationController
  before_filter :authenticate_account!, :except => [:create, :send_digest]
  respond_to :json

  def create
    data = params[:teacher]

    if data[:guard].blank? # => human entered registration data
      country = data[:country].blank? ? nil : Watan.where{ name =~ "%#{data[:country]}%" }.first

      teacher = Teacher.new name: data[:name]

      location = request.location
      city = state = country = zip = nil

      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = location.country
         # Mailbot.delay.registration_debug(city, state, zip, country)
         country = Watan.where{ name =~ country }.first
         country = country.id unless country.blank?
      end

      account_details = data[:account]
      account = teacher.build_account email: account_details[:email], 
                                      password: account_details[:password],
                                      password_confirmation: account_details[:password],
                                      city: city,
                                      state: state, 
                                      postal_code: zip,
                                      country: country
                                     
      if teacher.save 
        sign_in teacher.account
        redirect_to teacher_path
      end # no reason for else if client side validations worked
    else # registration data probably entered by a bot
      render json: { notify: { text: "Bot?" } }, status: :bad_request
    end
  end 

  def show 
    render nothing: true, layout: 'teachers'
  end 

  def load
    @teacher = Teacher.find params[:id]
  end

  def courses
    t = current_account.loggable
    @courses = Course.where(teacher_id: t.id)
  end 

  def worksheets
    teacher = current_account.loggable 
    head :bad_request if teacher.nil?
    @worksheets = teacher.worksheets
  end

  def update 
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?
    status = teacher.update_attributes(params[:teacher]) ? :ok : :bad_request
    head status 
  end 


  def list 
    if current_account
      @who_wants_to_know = current_account.role
      case @who_wants_to_know
        when :admin
          @teachers = Teacher.where(school_id: params[:id])
        when :school 
          @teachers = Teacher.where(school_id: current_account.loggable.id)
        when :student 
          @teachers = current_account.loggable.teachers 
        else 
          @teachers = [] 
      end 
      respond_with @teachers, @who_wants_to_know
    else
      head :bad_request 
    end 
  end 

  def sektions
    t = current_account.loggable
    all = t.sektions.order(:end_date).order(:name)
    @context = params[:context]
    @indie = t.indie 

    case params[:type]
      when 'inactive'
        @sektions = all.select{ |j| j.graduated? }
      when 'future'
        @sektions = all.select{ |j| j.future? }
      else
        @sektions = all.select{ |j| j.active? }
    end
    @sektions = Sektion.where(id: PREFAB_SECTION) if @sektions.blank?
  end

  def students 
    teacher = Teacher.find params[:id]
    all = (params[:exclusive] == "yes") ? false : true 
    @students = teacher.nil? ? [] : teacher.students(all).order(:first_name)
  end 

  def suggested_questions
    teacher = current_account.loggable_type == "Teacher" ? current_account.loggable : nil
    unless teacher.nil? 
      @questions = teacher.suggested_questions :completed
    else
      @questions = []
    end
  end

  def qzb_echo
    unless params[:checked].blank? 
      tids = params[:checked].keys.map(&:to_i)
      @topics = Topic.where(id: tids)
      @filters = params[:filter].blank? ? [] : params[:filter].keys
      @context = params[:context]
    else
      render json: { error: :no_topics, context: params[:context] }, status: :ok 
    end 
  end

  def prefabricate
    topic = params[:prefab][:topic]
    quiz = Quiz.find topic.to_i
    clone = quiz.clone current_account.loggable_id
    unless clone.nil?
      estimate = minutes_to_completion clone.job_id
      render json: { monitor: { quizzes: [clone.id] }, timer: { on: topic, for: "#{estimate * 60}"}}, status: :ok
    else
      render nothing: true, status: :ok
    end
  end 

  def lessons 
    # Return list of lessons made by this teacher
    t = current_account.loggable 
    @lessons = t.lessons 
  end 

  def add_lesson
    t = current_account.loggable
    p = params[:lesson]

    lsn = t.lessons.build title: p[:title], description: p[:description]

    youtube_url = p[:uid]
    v = youtube_url.match(/v=.*/)
    code = v.nil? ? nil : v.to_s.gsub(/v=/,'')
    lsn.build_video uid: code

    if lsn.save
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'failed' }, status: :ok
    end
  end

  def proficiency_chart
    s = Student.find params[:id]
    tid = current_account.loggable_id
    @json = s.proficiency_chart_for tid
  end

  def def_distribution_scheme
    e = Exam.find params[:id]
    unless e.nil?
      @eid = e.id
      @q = e.quiz
      @a = @q.teacher.apprentices.available
    else
      render json: { msg: 'Not found' }, status: :ok
    end
  end

  def set_distribution_scheme
    e = Exam.find params[:id]

    unless e.nil?
      scheme = params[:grid]
      a = {}
      for m in scheme.keys 
        a[m.to_i] = scheme[m].keys.map(&:to_i)  
      end 
      yaml = a.blank? ? nil : a.to_yaml
      e.reset if e.update_attribute(:dist_scheme, yaml)
    end
    render json: { msg: :ok }, status: :ok
  end

  def send_digest
    n = params[:n].blank? ? 7 : params[:n].to_i
    type = params[:type] == 'uploads' ? :uploads : :summary
    tryouts = Tryout.received_in_last(n)
    unless tryouts.blank?
      w = tryouts.map(&:worksheet).uniq 
      e = w.map(&:exam).uniq  
      q = Exam.where(id: e.map(&:id)).map(&:quiz).uniq 
      t = Quiz.where(id: q.map(&:id)).map(&:teacher).uniq 
      t.each do |m| 
        type == :summary ? m.send_digest(n,e,q) : m.send_upload_summary(q,e,w,tryouts)
      end 
    end 
    render json: { status: :ok }, status: :ok
  end 


end # of class
