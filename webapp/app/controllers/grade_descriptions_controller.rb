class GradeDescriptionsController < ApplicationController
  before_filter :authenticate_account! 

  def new
  end

  def update
    # params => {:benchmarks => { 1 => {:annotation => .....}, .... } }
    benchmarks = params[:benchmarks] 
    benchmarks.each { |id, attributes| 
      grade_desc = GradeDescription.find(id.to_i) 
      unless grade_desc.nil? 
        grade_desc.update_attributes(attributes)
      end 
    }
    redirect_to :back
  end

  def create
  end

end
