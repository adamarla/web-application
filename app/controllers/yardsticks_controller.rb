class YardsticksController < ApplicationController
  before_filter :authenticate_account! 
  respond_to :json 

  def new
  end

  def update 
    yardstick = Yardstick.where(:id => params[:id]).first
    head :bad_request if yardstick.nil?
    ok = yardstick.update_attributes params[:yardstick]
    if ok
      render :json => { :status => "Updated" }, :status => :ok
    else
      render :json => { :status => "Oops!" }, :status => :bad_request
    end
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
    @yardsticks = Yardstick.order('mcq DESC').order(:default_allotment)
  end

  def logical_next
    head :bad_request if params[:i].blank? 

    @logical = Calibration.where(:insight_id => params[:i])

    unless params[:f].blank?
      @logical = @logical.where(:formulation_id => params[:f])
      @logical = @logical.where(:calculation_id => params[:c]) unless params[:c].blank?
    end
  end

end
