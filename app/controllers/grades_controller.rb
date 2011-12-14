class GradesController < ApplicationController
  before_filter :authenticate_account!

  def update
    # params => {:grades => {1 => "60", 4 => "30", ....} .... }
    grades = params[:grades] 
    status = :ok 

    grades.each { |id, allotment| 
      grade = Grade.find(id) 
      unless grade.nil? 
        status = grade.update_attribute(:allotment, allotment) ? :ok : :bad_request
      else
        status = :bad_request
      end 
      break if status == :bad_request 
    } 
    head status 
  end

end
