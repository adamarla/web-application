class TeachersController < ApplicationController
  def show 
    @teacher = params[:id].nil? ? current_account.loggable : 
                                  Teacher.find(params[:id])
    if @teacher.grades.empty? 
      # Create default grades for this teacher
      Yardstick.all.each { |d| 
        grade = @teacher.grades.new :yardstick_id => d.id,
                                    :allotment => d.default_allotment
        grade.save
      } 
    end 
    @grades = @teacher.grades
  end 

  def update 
    head :ok 
#    grades = params[:grades] 
#    status = :ok 
#
#    grades.each { |id, allotment|
#      grade = Grade.find(id) 
#      status = (grade && grade.update_attribute(:allotment, allotment)) ? :ok : :bad_request
#      break if status == :bad_request 
#    } 
#    head status 
  end 

end # of class
