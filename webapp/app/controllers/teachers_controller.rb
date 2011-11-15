class TeachersController < ApplicationController
  def show 
    @teacher = params[:id].nil? ? current_account.loggable : 
                                  Teacher.find(params[:id])
    if @teacher.grades.empty? 
      # Create default grades for this teacher
      GradeDescription.all.each { |d| 
        grade = @teacher.grades.new :grade_description_id => d.id,
                                    :allotment => d.default_allotment
        grade.save
      } 
    end 
    @grades = @teacher.grades
  end 

  def update 
    render :nothing => true 
  end 

end # of class
