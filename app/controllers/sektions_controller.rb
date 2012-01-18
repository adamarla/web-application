class SektionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json 

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil? 

    # {:klasses => {:from => '9', :to => '11'}, :sections => {:from => 'A', :to => 'F'}}
    kfrom = params[:klasses][:from].to_i
    kto = params[:klasses][:to].to_i

    if kfrom > kto 
      x = kfrom 
      kfrom = kto 
      kto = x
    end 
    klasses = [*kfrom..kto]

    sfrom = params[:sections][:from]
    sto = params[:sections][:to]

    if sfrom > sto 
      x = sfrom 
      sfrom = sto 
      sto = x
    end 
    sections = [*sfrom..sto]

    head ( school.create_sektions(klasses, sections) ? :ok : :bad_request ) 
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
      respond_with @sektions.order(:klass).order(:section)
    else
      head :bad_request 
    end 
  end # of action 

  def update_student_list 
    section = Sektion.find params[:id] 
    head :bad_request if section.nil? 

    section.update_student_list params[:checked]
    head :ok
  end 

  def students 
    @students = Student.where(:sektion_id => params[:id]).order(:first_name)
    @who_wants_to_know = current_account.nil? ? :guest : current_account.role
  end 

end
