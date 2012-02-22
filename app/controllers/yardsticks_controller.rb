class YardsticksController < ApplicationController
  before_filter :authenticate_account! 
  respond_to :json 

  def new
  end

  def update 
    yardstick = Yardstick.where(:id => params[:id]).first
    head :bad_request if yardstick.nil?
    head (yardstick.update_attribute(:default_allotment, params[:yardstick][:default_allotment]) ? :ok : :bad_request)
  end 

  def create
    @yardstick = Yardstick.new params[:yardstick] 

    # A newly created yardstick should be made available 
    # to all teachers as a new grade
    new_grades = [] 
    Teacher.all.each { |teacher| 
      new_grades << @yardstick.grades.new( :teacher_id => teacher.id, 
                                              :allotment => @yardstick.default_allotment )
    } 

    @yardstick.save ? respond_with(@yardstick) : head(:bad_request) 
  end

  def show 
    @yardstick = Yardstick.find params[:id] 
    @yardstick.nil? ? (head :bad_request) : (respond_with @yardstick)
  end 

  def preview
    @yardsticks = Yardstick.order(:default_allotment).order(:mcq)
  end

end
