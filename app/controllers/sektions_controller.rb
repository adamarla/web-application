class SektionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 


  def create 
    teacher = Teacher.find params[:id]
    name = params[:name]
    sk = name.nil? ? nil : teacher.sektions.build(:name => name)
    if sk.nil?
      render :json => { :notify => { :text => "No name given to section" } }, :status => :ok
    else
      saved = sk.save
      render :json => { :notify => { :text => "#{saved ? '#{name} created' : 'Error saving #{name}'}" } }, :status => :ok
    end
  end 

  def update 
    sektion = Sektion.find params[:id]
    student_ids = params[:checked].keys.map(&:to_i)

=begin
    Do NOT change the relative order of the next 2 lines !!
    The first line updates the StudentRoster table - not Sektion
    The second line updates the Sektion object 

    Request for re-generation of roster PDF is tied to (2). So, (2) must
    happen AFTER (1)
=end
    sektion.student_ids = student_ids
    render :json => { :status => "updated" }, :status => :ok
  end 

  def update_student_list 
    section = Sektion.find params[:id] 
    head :bad_request if section.nil? 

    render :json => { :status => "Done" }, :status => (section.update_student_list(params[:checked]) ? :ok : :bad_request)
  end 

  def students 
    @sektion = Sektion.find params[:id]
    @students = @sektion.students.order(:first_name)
    @context = params[:context]
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
