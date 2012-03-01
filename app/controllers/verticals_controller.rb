class VerticalsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    vertical = Vertical.new :name => params[:vertical][:name]
    vertical.save ? head(:ok) : head(:bad_request)
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
