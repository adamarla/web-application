class TeachersController < ApplicationController
  before_filter :authenticate_account!
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

  def list 
    if current_account
      case current_account.role 
        when :admin
          @teachers = Teacher.where(:school_id => params[:school_id])
        when :school 
          @teachers = Teacher.where(:school_id => current_account.loggable.id)
        when :student 
          @teachers = current_account.loggable.teachers 
        else 
          @teachers = [] 
      end 
    else
      head :bad_request 
    end 
  end 

end # of class
