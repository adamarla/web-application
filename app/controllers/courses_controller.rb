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
    @questions = course.questions_on @topic

=begin
    tid = current_account.loggable_id # has to be a teacher. If not, then sth is wrong !
    skip_used = params[:skip_previously_used] == "true" ? true : false
    favs_only = params[:liked] == "true" ? true : false
    suggested = params[:suggested] == "true" ? true : false
    topic_ids = params[:checked].keys.map(&:to_i)

    show = course.questions_on(topic_ids, (skip_used ? tid : nil)).map(&:id)

    # Filteration order 
    #   1. previously used 
    #   2. favs 
    #   3. suggested - only if favs_only = false

    show = Favourite.where(:teacher_id => tid).map(&:question_id) & show if favs_only
    if suggested 
      show = Suggestion.where(:teacher_id => tid).map(&:question_ids).flatten & show unless favs_only
    end
    @questions = Question.where(:id => show) 
=end
=begin
    Paying customers can see any question relevant to their syllabus. 
    Non-paying customers - who might only be trialing - see a smaller set 
    of questions. The code below realizes this logic
=end

=begin
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
    @fav = current_account.nil? ? [] : Favourite.where(:teacher_id => current_account.loggable_id).map(&:question_id)
    @fav = @fav & @questions.map(&:id) 
    respond_with @questions, @topics, @fav
=end
  end

end
