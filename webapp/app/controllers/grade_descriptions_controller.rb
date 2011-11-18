class GradeDescriptionsController < ApplicationController
  before_filter :authenticate_account! 

  def new
  end

  def update
    # params => {:benchmarks => { 1 => {:annotation => .....}, .... } }
    benchmarks = params[:benchmarks] 
    status = :ok 

    benchmarks.each { |id, attributes| 
      grade_desc = GradeDescription.find(id.to_i) 
      unless grade_desc.nil? 
        status = grade_desc.update_attributes(attributes) ? :ok : :bad_request
        break if status == :bad_request
      end 
    }
    head status # simply return HTTP headers with HTTP status code
  end

  def create
  end

end
