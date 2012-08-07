class TeachersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 

    names = params[:names]
    success = true 

    names.each do |slot, name|
      next if name.blank?
      @teacher = school.teachers.build :name => name
      username = create_username_for @teacher, :teacher
      email = "#{username}@drona.com"
      password = school.zip_code

      unless username.nil?
        account = @teacher.build_account :email => email, :username => username, 
                      :password => password, :password_confirmation => password 
        success &= @teacher.save 
      else
        success = false
      end
    end # of each 

    success ? render(:json => { :status => "done" }, :status => :ok) : head(:bad_request)
  end # of create
 
  def show 
    render :nothing => true, :layout => 'teachers'
  end 

  def load
    @teacher = Teacher.find params[:id]
  end

  def coverage
    # Returns the list of verticals covered by the teacher for the passed
    # (class, subject, board) combo

    teacher = (current_account.role == :teacher) ? current_account.loggable : nil
    head :bad_request if teacher.nil?

    subject = params[:criterion][:subject]
    klass = params[:criterion][:klass]
    board = teacher.school.board_id

    course = Course.where(:board_id => board, :klass => klass, :subject_id => subject).first
    @verticals = course.nil? ? nil : course.verticals
    @verticals.nil? ? head(:bad_request) : respond_with(@verticals)
  end

  def topics_this_section
    teacher = Teacher.find params[:id]
    sektion = Sektion.find params[:section_id]
    head :bad_request if (teacher.nil? || sektion.nil?)
    subject = teacher.subjects.first 
    board = teacher.school.board_id
    course = Course.where(:board_id => board, :klass => sektion.klass, :subject_id => subject.id).first
    @topics = course.topics
  end

  def courses
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil? 
    @courses = teacher.courses
  end

  def testpapers
    teacher = Teacher.find params[:id]
    head :bad_request if teacher.nil?
    @testpapers = teacher.testpapers
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

=begin
  def roster 
    @teacher = Teacher.find params[:id] 
    head :bad_request if @teacher.nil? 

    @sektions = Sektion.where(:school_id => @teacher.school_id).order(:klass).order(:name)
    respond_with @sektions, @teacher
  end 

  def update_roster
    teacher = Teacher.find params[:id] 
    head :bad_request if teacher.nil? 

    roster = params[:checked] # a hash with (key, value) = (id, boolean)
    retain = [] 

    roster.each { |id, teaches| 
      sektion = Sektion.find id 
      unless sektion.nil? 
        retain << sektion if teaches 
      end 
    }
    teacher.sektions = retain 
    render :json => { :status => 'Done' }, :status => :ok
  end 
=end

  def specializations
    @subjects = Subject.all
    @teacher = Teacher.find params[:id]
  end 

  def update_specialization
    teacher = Teacher.find params[:id]
    new_object_ids = [] 

    params[:subject].keys.each do |m|
      s_id = m.to_i
      klasses = params[:subject][m].keys.map(&:to_i)
      klasses.each do |k|
        s = Specialization.where(:teacher_id => teacher.id, :klass => k, :subject_id => s_id).first
        s = teacher.specializations.create(:subject_id => s_id, :klass => k) if s.nil?
        new_object_ids.push s.id
      end
    end 
    teacher.specialization_ids = new_object_ids 
    render :json => { :status => "Done" }, :status => :ok
  end 
  
  def sektions
    @teacher = Teacher.find params[:id]
    @sektions = @teacher.nil? ? [] : @teacher.sektions
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

  def build_quiz 
    teacher = Teacher.find params[:id]
    course = Course.find params[:course_id]
    head :bad_request if (teacher.nil? || course.nil?)

    question_ids = params[:checked].keys.map(&:to_i)
    name = params[:quiz_name]

    Delayed::Job.enqueue BuildQuiz.new(name, teacher.id, question_ids, course), :priority => 0, :run_at => Time.zone.now
    at = Delayed::Job.where('failed_at IS NULL').count
    render :json => { :status => "Queued", :at => at }, :status => :ok
  end

  def like_question
    tid = current_account.loggable_id
    teacher = Teacher.find tid
    unless teacher.nil?
      qid = params[:id].to_i
      teacher.like_question qid
      head :ok
    else
      head :bad_request
    end
  end

  def unlike_question
    tid = current_account.loggable_id
    teacher = Teacher.find tid
    unless teacher.nil?
      qid = params[:id].to_i
      teacher.unlike_question qid
      head :ok
    else
      head :bad_request
    end
  end

end # of class
