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
      if current_account.loggable_type == "Teacher"
        ids = @topics.map(&:id)
        if @context == "deepdive"
          questions_used = QSelection.where(:quiz_id => Quiz.where(:teacher_id => current_account.loggable_id)).map(&:question)
          topics_used = questions_used.map(&:topic_id)
        else
          topics_used = Question.where(:topic_id => ids).map(&:topic_id).uniq
        end
        @unused = ids - topics_used
      else
        @unused = []
      end
    else
      head :bad_request
    end
  end

  def list
    @verticals = Vertical.where('id IS NOT NULL').order(:name)
  end 

end #of controller
