class MacroTopicsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def micros_in_course
    me = MacroTopic.find params[:id]
    unless me.nil? 
      @course = Course.find params[:course]
      @micros = MicroTopic.where :macro_topic_id => me.id 
      respond_with @course, @micros
    else 
      head :bad_request
    end
  end 

end #of controller
