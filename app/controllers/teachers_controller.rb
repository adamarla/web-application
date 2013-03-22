class TeachersController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    info = params[:register]
    country = Country.where{ name =~ "%#{info[:country]}%" }.first unless info[:country].blank?
    teacher = country.nil? ? Teacher.new(:name => info[:name]) : 
                             Teacher.new(:name => info[:name], :country_id => country.id)
    username = create_username_for teacher, :teacher
    account = teacher.build_account :email => info[:email], :password => info[:password],
                                    :password_confirmation => info[:password], :trial => false,
                                    :username => username
    teacher.zip_code = info[:zip].blank? ? nil : info[:zip]
    if teacher.save 
      render :json => { :notify => { :text => "Registration Successful" }}, :status => :ok
    else
      render :json => { :errors => { :email => teacher.account.errors[:email], 
                                     :password => teacher.account.errors[:password] }},
                                     :status => :bad_request
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
    @sektions = teacher.nil? ? [] : teacher.sektions
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
      quiz.update_attribute :uid, job.id.to_s
      render :json => { :monitor => { :quiz => quiz.id } }, :status => :ok
    else
      render :json => { :monitor => { :quiz => nil } }, :status => :ok
    end
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
