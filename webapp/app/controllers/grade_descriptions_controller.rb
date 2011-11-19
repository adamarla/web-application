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
    new_grade = GradeDescription.new params[:grade_description] 
    status = new_grade.save ? :ok : :bad_request 
    head status 
  end

end
