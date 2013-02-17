class SektionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 


  def create 
    teacher = Teacher.find params[:id]
    name = params[:name]
    exclusive = params[:exclusive].blank? ? false : true

    for_now = teacher.klasses.first
    @sektion = Sektion.new :name => name, :school_id => teacher.school_id,
                           :klass => for_now, :teacher_id => teacher.id, :exclusive => exclusive
    head :bad_request unless @sektion.save
  end 

  def update 
    sektion = Sektion.find params[:id]
    student_ids = params[:checked].keys.map(&:to_i)

    # The klass/grade of a sektion is the klass of the majority of students 
    # in that sektion OR the higher klass - in case of equal # of students 

    klasses = Student.where(:id => student_ids).map(&:klass)
    n_occurrences = [*9..12].map{ |m| klasses.count m }
    klass = [*9..12].at(n_occurrences.index n_occurrences.max)

=begin
    Do NOT change the relative order of the next 2 lines !!
    The first line updates the StudentRoster table - not Sektion
    The second line updates the Sektion object 

    Request for re-generation of roster PDF is tied to (2). So, (2) must
    happen AFTER (1)
=end
    sektion.student_ids = student_ids
    sektion.update_attribute :klass, klass 
    render :json => { :status => "updated" }, :status => :ok
  end 

  def list 
    if current_account
      case current_account.role 
        when :admin
          @sektions = Sektion.where(:school_id => params[:school_id]) 
        when :school 
          @sektions = Sektion.where(:school_id => current_account.loggable.id) 
        when :student 
          @sektions = Sektion.where(:id => current_account.loggable.sektion_id)
        else 
          @sektions = [] 
      end 
      respond_with @sektions.order(:klass).order(:name)
    else
      head :bad_request 
    end 
  end # of action 

  def update_student_list 
    section = Sektion.find params[:id] 
    head :bad_request if section.nil? 

    render :json => { :status => "Done" }, :status => (section.update_student_list(params[:checked]) ? :ok : :bad_request)
  end 

  def students 
    @sektion = Sektion.find params[:id]
    @students = @sektion.students.order(:first_name)
  end 

  def proficiency
    sektion = Sektion.find params[:of]
    @topic = Topic.find params[:in]
    head :bad_request if (sektion.nil? || @topic.nil?)

    teacher = current_account.loggable
    quizzes = Quiz.where(:teacher_id => teacher.id) # all quizzes by teacher
    selections = QSelection.where(:quiz_id => quizzes.map(&:id)).on_topic(@topic.id) # all questions on topic
    responses = GradedResponse.where(:q_selection_id => selections.map(&:id).uniq).graded # all responses to those questions

    subparts = Subpart.where(:question_id => selections.map(&:question_id).uniq)
    @avg = (subparts.map(&:marks).inject(:+) / subparts.count.to_f).round(2)
    @db_avg = @topic.benchmark
    
    @proficiency = sektion.students.map do |s|
      graded = responses.where(:student_id => s.id)
      unless graded.empty?
        # total = Subpart.where(:id => graded.map(&:subpart_id)).map(&:marks).inject(:+)
        total = graded.map(&:subpart).map(&:marks).inject(:+) # takes care of the case when a question is repeated 
        scored = graded.map(&:system_marks).inject(:+)
        {:id => s.id, :score => (scored / total.to_f).round(2)}
      else
        { :id => s.id, :score => -1 }
      end
    end 
  end # of method

end
