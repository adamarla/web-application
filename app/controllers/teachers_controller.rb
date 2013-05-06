class TeachersController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    data = params[:teacher]

    if data[:guard].blank? # => human entered registration data
      country = data[:country].blank? ? nil : Country.where{ name =~ "%#{data[:country]}%" }.first

      teacher = Teacher.new :name => data[:name]

      location = request.location
      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = location.country
         Mailbot.registration_debug(city, state, zip, country, true).deliver
         country = Country.where{ name =~ country }.first
         country = country.id unless country.blank?
      else
        city = state = country = zip = nil
        Mailbot.registration_debug(city, state, zip, country, false).deliver
      end

      account_details = data[:account]
      account = teacher.build_account :email => account_details[:email], 
                                      :password => account_details[:password],
                                      :password_confirmation => account_details[:password],
                                      :city => city,
                                      :state => state, 
                                      :zip_code => zip,
                                      :country => country
                                     
      if teacher.save 
        # Mailbot.welcome_teacher(teacher.account).deliver
        sign_in teacher.account
        redirect_to teacher_path
      end # no reason for else if client side validations worked
    else # registration data probably entered by a bot
      render :json => { :notify => { :text => "Bot?" } }, :status => :bad_request
    end
  end 

  def show 
    render :nothing => true, :layout => 'teachers'
  end 

  def load
    @teacher = Teacher.find params[:id]
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
          @teachers = Teacher.where(:school_id => params[:id])
        when :school 
          @teachers = Teacher.where(:school_id => current_account.loggable.id)
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
    teacher = params[:id].nil? ? current_account.loggable : Teacher.find(params[:id])
    if teacher.nil?
      @sektions = []
    else
      @sektions = teacher.sektions
      @sektions = Sektion.where(:id => 58) if @sektions.blank?
    end
    @context = params[:context]
  end

  def students 
    teacher = Teacher.find params[:id]
    all = (params[:exclusive] == "yes") ? false : true 
    @students = teacher.nil? ? [] : teacher.students(all).order(:first_name)
  end 

  def students_with_names
    teacher = Teacher.find params[:id]
    all = (params[:exclusive] == "yes") ? false : true 
    starting_with = [*"#{params[:start]}".."#{params[:end]}"]
    @students = teacher.nil? ? [] : teacher.students(all, starting_with)
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
    tids = params[:checked].keys.map(&:to_i)
    @topics = Topic.where(:id => tids)
    @filters = params[:filter].blank? ? [] : params[:filter].keys
    @context = params[:context]
  end

  def build_quiz 
    teacher_id = current_account.loggable_type == "Teacher" ? current_account.loggable_id : nil
    head :bad_request if teacher_id.nil? 

    name = params[:checked].delete :name
    question_ids = params[:checked].keys.map(&:to_i)
    quiz = Quiz.new :name => name, :teacher_id => teacher_id, 
                    :question_ids => question_ids, 
                    :num_questions => question_ids.count

    status = quiz.save ? :ok : :bad_request
    unless status == :bad_request
      job = Delayed::Job.enqueue CompileQuiz.new(quiz)
      quiz.update_attribute :job_id, job.id

      estimate = minutes_to_completion job.id
      render :json => { :monitor => { :quiz => quiz.id }, 
                        :notify => { :title => "#{estimate} minute(s)" }},
                        :status => :ok
    else
      render :json => { :monitor => { :quiz => nil } }, :status => :ok
    end
  end

  def disputed 
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?

    @disputed = GradedResponse.in_quiz(teacher.quiz_ids).disputed
    quiz_ids = QSelection.where(:id => @disputed.map(&:q_selection_id)).map(&:quiz_id).uniq
    @quizzes = Quiz.where(:id => quiz_ids)
  end

  def overwrite_marks
    params[:disputed].each do |id, marks|
      g = GradedResponse.where(:id => id).first
      marks = marks.empty? ? nil : marks.to_f.round(2)
      next if marks.nil? || marks < 0 || marks > g.subpart.marks
      g.update_attributes :marks_teacher => marks, :closed => true
    end
    render :json => { :status => :done }, :status => :ok
  end

end # of class
