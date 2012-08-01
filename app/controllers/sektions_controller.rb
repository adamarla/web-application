class SektionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 


  def create 
    teacher = Teacher.find params[:id]
    name = params[:sektion][:name]
    student_ids = params[:checked].keys.map(&:to_i)

    # The klass/grade of a sektion is the klass of the majority of students 
    # in that sektion OR the higher klass - in case of equal # of students 
    klasses = Student.where(:id => student_ids).map(&:klass)
    n_occurrences = [*9..12].map{ |m| klasses.count m }
    klass = [*9..12].at(n_occurrences.index n_occurrences.max)

    sektion = teacher.sektions.build :name => name, :school_id => teacher.school_id, :klass => klass
    if sektion.save
      sektion.student_ids = student_ids
      render :json => { :status => "Done" }, :status => :ok
    else
      head :bad_request 
    end
  end 

  def list 
    if current_account
      case current_account.role 
        when :admin
          @sektions = Sektion.where(:school_id => params[:school_id]) 
        when :school 
          @sektions = Sektion.where(:school_id => current_account.loggable.id) 
        when :student 
          @sektions = Sektion.where(:id => current_account.loggable.sektion_id)
        else 
          @sektions = [] 
      end 
      respond_with @sektions.order(:klass).order(:name)
    else
      head :bad_request 
    end 
  end # of action 

  def update_student_list 
    section = Sektion.find params[:id] 
    head :bad_request if section.nil? 

    render :json => { :status => "Done" }, :status => (section.update_student_list(params[:checked]) ? :ok : :bad_request)
  end 

  def students 
    sektion = Sektion.find params[:id]
    @students = sektion.students.order(:first_name)
    @who_wants_to_know = current_account.nil? ? :guest : current_account.role
  end 

  def proficiency
    sektion = Sektion.find params[:id]
    @topic = Topic.find params[:topic]
    head :bad_request if (sektion.nil? || @topic.nil?)
    @students = sektion.students
    respond_with @students, @topic
  end

end
