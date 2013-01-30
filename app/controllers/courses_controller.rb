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
    name = params[:course][:name]
    unless name.empty?
      course = Course.new :name => name
      if course.save
        course.update_syllabus params[:difficulty]
        render :json => { :status => "done" }, :status => :ok
      else
        render :json => { :status => "phat gayee!" }, :status => :bad_request
      end
    else
      render :json => { :status => "give a name" }, :status => :bad_request
    end
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
    @topics = Topic.order(:id) # basically, every topic 
    @course = params[:id]

    respond_with @course, @topics
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
    @vertical_id = params[:vertical].to_i
    @topics = course.topics_in @vertical_id
  end

  def questions
    course = Course.find params[:id]
    head :bad_request if course.nil? 

    @topic = params[:topic].to_i
    filters = params[:filter].blank? ? [] : params[:filter].keys
    teacher = current_account.loggable_id

    @questions = filters.include?("repeated") ? 
        course.questions_on(@topic, teacher) : 
        course.questions_on(@topic)

    qids = @questions.map(&:id)

    if filters.include? "suggested"
      suggested = Suggestion.where(:teacher_id => teacher).completed.map(&:question_ids).flatten
      qids &= suggested
    end

    if filters.include? "liked"
      liked = Favourite.where(:teacher_id => teacher).map(&:question_id)
      qids &= liked
    end
    @questions = Question.where(:id => qids)
  end

end
