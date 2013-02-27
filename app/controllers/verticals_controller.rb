class VerticalsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    added = true
    params[:names].each_value do |v|
      next if v.blank?
      vertical = Vertical.new :name => v
      added &= vertical.save
      break if !added
    end 

    if added 
      @verticals = Vertical.order :name 
      respond_with @verticals
    else
      head :bad_request
    end
  end

  def show
    @verticals = Vertical.order :name
  end

  def topics
    @vertical = Vertical.find params[:id]
    @context = params[:context]
    @is_admin = current_account.role? :admin

    unless @vertical.nil?
      @topics = @vertical.topics
      if (current_account.loggable_type == "Teacher" && @context == "deepdive") 
        ids = @topics.map(&:id)
        questions_used = QSelection.where(:quiz_id => Quiz.where(:teacher_id => current_account.loggable_id)).map(&:question)
        topics_used = questions_used.map(&:topic_id)
        @unused = ids - topics_used # operation ensures that all topics belong_to same vertical
      else
        @unused = []
      end
    else
      head :bad_request
    end
  end

  def topics_in_course
    me = Vertical.find params[:id]
    unless me.nil? 
      @course = Course.find params[:course]
      @topics = Topic.where :vertical_id => me.id 
      respond_with @course, @topics
    else 
      head :bad_request
    end
  end 

  def list
    @verticals = Vertical.where('id IS NOT NULL').order(:name)
  end 

end #of controller
