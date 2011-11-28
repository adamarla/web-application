class YardsticksController < ApplicationController
  before_filter :authenticate_account! 
  respond_to :json 

  def new
  end

  def update
    # params => {:yardsticks => { 1 => {:annotation => .....}, .... } }
    yardsticks = params[:yardsticks] 
    status = :ok 

    yardsticks.each { |id, attributes| 
      yardstick = Yardstick.find(id.to_i) 
      unless yardstick.nil? 
        status = yardstick.update_attributes(attributes) ? :ok : :bad_request
        break if status == :bad_request
      end 
    }
    head status # simply return HTTP headers with HTTP status code
  end

  def create
    new_yardstick = Yardstick.new params[:yardstick] 

    # A newly created yardstick should be made available 
    # to all teachers as a new grade
    new_grades = [] 
    Teacher.all.each { |teacher| 
      new_grades << new_yardstick.grades.new( :teacher_id => teacher.id, 
                                              :allotment => new_yardstick.default_allotment )
    } 
    status = new_yardstick.save ? :ok : :bad_request 
    head status 
  end

  def list 
    @yardsticks = Yardstick.all 
	respond_with @yardsticks 
  end 

end
