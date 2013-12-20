class SektionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def ping
    @sk = Sektion.find params[:id]
  end

  def create 
    sektion = params[:new][:sektion]
    unless sektion.blank?
      teacher = current_account.loggable
      @sk = teacher.sektions.build :name => sektion
      unless @sk.save
        render :json => { :notify => { :text => @sk.errors[:name] } }, :status => :bad_request
      end
    else
      render :json => { :notify => { :text => "No name for sektion" } }, :status => :bad_request
    end
  end 

  def update 
    sektion = Sektion.find params[:id]
    editable = (sektion && (sektion.teacher_id == current_account.loggable_id))

    if editable
      student_ids = sektion.student_ids
      @removed = params[:checked].keys.map(&:to_i)
      retain = student_ids - @removed
      sektion.student_ids = retain
    else
      render :json => { 
        :notify => { 
          :text => "Update failed", 
          :subtext => "Cannot update someone else's section" 
        } }, :status => :ok
    end
  end 

  def students 
    @sektion = Sektion.find params[:id]
    @students = @sektion.students.order(:first_name)
    @context = params[:context]

    if @context == 'wsb'
      ws_ids = Testpaper.where(:quiz_id => params[:quiz]).map(&:id)
      past_takers = Worksheet.where(:testpaper_id => ws_ids).map(&:student_id).uniq
      @disabled = @students.map(&:id) & past_takers
    else
      @disabled = []
    end
  end 

  def proficiency
    sektion = Sektion.find params[:of]
    @topic = Topic.find params[:in]
    head :bad_request if (sektion.nil? || @topic.nil?)

    teacher = current_account.loggable

    quizzes = Quiz.where(:teacher_id => teacher.id) # all quizzes by teacher
    quizzes = quizzes.blank? ? Quiz.where(:id => 318) : quizzes # 318 = "A Demo Quiz" 

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

  def preview_names
    names = params[:add][:names]
    @lines = names.split("\r\n").select{ |m| !m.blank? }
  end

  def enroll_named_students
    sk = params[:id].blank? ? nil : Sektion.find(params[:id])

    unless sk.nil?
      students = params[:checked].values
      saved = true
      new_student_ids = [] 

      for m in students
        s = Student.new :name => m
        username = create_username_for s, :student
        a = s.build_account :email => "#{username}@drona.com", 
                            :password => "123456", 
                            :password_confirmation => "123456"
        if s.save
          new_student_ids.push s.id
        else
          saved = false
        end
      end
      if saved
        enrolled = sk.student_ids 
        sk.student_ids = (enrolled + new_student_ids).uniq 
        render :json => { :notify => { :title => "#{students.count} students added to group" } }, :status => :ok
      else
        render :nothing => true, :status => :ok
      end
    else # sektion not found!
      render :json => { :notify => { :title => "Group not found!" } }, :status => :ok
    end 
  end

end
