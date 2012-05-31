class CoursesController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def profile
    @course = Course.find params[:id]
  end

  def show 
    @course = Course.find(params[:id]) 
    @syllabi = Syllabus.where(:course_id => @course.id)
    respond_with @course, @syllabi 
  end 

  def update 
    course = Course.find params[:id] 
    status = :ok
    
    status = course.nil? ? :bad_request : 
            (course.update_attributes(params[:course]) ? :ok : :bad_request)
    head status 
  end 

  def search 
    head :ok
  end 

  def create 
   board_name = params[:course].delete :board 
   unless board_name.empty? 
     board = Board.where(:name => board_name).first 
     board = board.nil? ? Board.new(:name => board_name) : board 
     board.save if board.new_record? # Have to save board first else @course.board_id = nil
     @course = board.courses.new params[:course]
   else  
     @course = Course.new params[:course] 
   end 
   @course.save ? respond_with(@course) : head(:bad_request) 
  end 

  def list
    criterion = params[:criterion]
    unless criterion.nil?
      klass = criterion[:klass]
      subject = criterion[:subject]
      board = criterion[:board]
    else
      klass = subject = board = nil
    end 
    @courses = Course.klass?(klass).subject?(subject).board?(board)
  end 

  def coverage
    @course = Course.find params[:id]
    @verticals = Vertical.where('id IS NOT NULL').order(:name) # basically, everyone
  end 

  def verticals
    course = Course.find params[:id]
    head :bad_request if course.nil?
    @verticals = course.verticals
  end

  def applicable_topics 
    vertical_ids = params[:checked].keys.map(&:to_i)
    @topics = Topic.where(:vertical_id => vertical_ids).order(:vertical_id).order(:name)
  end 

  def topics_in
    course = Course.find params[:id]
    vertical = params[:vertical].to_i
    @topics = course.topics_in vertical
  end

  def questions
    course = Course.find params[:id]
    head :bad_request if course.nil? 

    skip_used = params[:skip_previously_used] == "true" ? true : false
    teacher = skip_used ? params[:teacher_id].to_i : nil

    topic_ids = params[:checked].keys.map(&:to_i)
    @questions = course.questions_on topic_ids, teacher

=begin
    Paying customers can see any question relevant to their syllabus. 
    Non-paying customers - who might only be trialing - see a smaller set 
    of questions. The code below realizes this logic
=end

    unless current_account.nil?
      case current_account.loggable_type
        when "Examiner"
        when "Teacher"
          @questions = current_account.trial ? @questions.select{ |m| m.restricted == false } : @questions
        else 
          @questions = @questions.select{ |m| m.topic_id == -1 } # basically, nothing 
      end
    else
      @questions = @questions.select{ |m| m.topic_id == -1 } # basically, nothing
    end
    @topics = Topic.where(:id => topic_ids)
    respond_with @questions, @topics
  end

end
