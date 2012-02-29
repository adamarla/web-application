class VerticalsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def micros_in_course
    me = Vertical.find params[:id]
    unless me.nil? 
      @course = Course.find params[:course]
      @micros = MicroTopic.where :vertical_id => me.id 
      respond_with @course, @micros
    else 
      head :bad_request
    end
  end 

  def list
    @verticals = Vertical.where('id IS NOT NULL').order(:name)
  end 

end #of controller
