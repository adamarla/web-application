class TeachersController < ApplicationController
  respond_to :json
  before_filter :authenticate_account!

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 
    
    options = params[:teacher]
    @teacher = school.teachers.new :first_name => options[:first_name],
                                  :last_name => options[:last_name]

    (@teacher.save ? respond_with(@teacher) : head(:bad_request)) 
  end 

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
      respond_with @teachers
    else
      head :bad_request 
    end 
  end 

  def roster 
    @teacher = Teacher.find params[:teacher_id] 
    head :bad_request if @teacher.nil? 

    @study_groups = StudyGroup.where(:school_id => @teacher.school_id)
    respond_with @study_groups, @teacher
  end 

  def update_roster
    teacher = Teacher.find params[:teacher_id] 
    head :bad_request if teacher.nil? 

    roster = params[:roster] # a hash with (key, value) = (id, boolean)
    roster.each { |id, teaches| 
      study_group = StudyGroup.find id 
      unless study_group.nil? 
        teacher.study_groups << study_group if teaches 
      end 
    }
    head :ok
  end 

end # of class
