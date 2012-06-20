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
    me = Vertical.find params[:id]
    unless me.nil?
      @topics = me.topics
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
