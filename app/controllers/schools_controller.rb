class SchoolsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!
  respond_to :json 

  def create 
    email = params[:school].delete :email # email -> Account model 
    currency = params[:school].delete :currency # currency -> Customer model
    @school = School.new params[:school] 
    username = username_for @school, :school 
    email = email || "#{username}@drona.com"

    @school.build_account email: email, username: username, 
                          password: "gradians", password_confirmation: "gradians"
    @school.save ? respond_with(@school) : head(:bad_request)
  end 

  def show 
    @school = School.find params[:id]
    head :bad_request if @school.nil?
  end 

  def list
    @schools = School.order(:name)
  end

  def find
    @schools = School.where{ name =~ params[:query] }
  end

  def update 
    school = School.find params[:id] 
    status = :ok

    unless school.nil? 
      active = params[:account][:active] == 'true' ? true : false 
      status = school.update_attributes(params[:school]) ? :ok : :bad_request
      unless status == :bad_request
        status = school.account.update_attribute(:active, active) ? :ok : :bad_request
      end
    else 
      status = :bad_request 
    end 

    render(json: { status: "Done" }, status: status) if status == :ok
    render(json: { status: "Update failed!" }, status: status) if status == :bad_request
  end 

=begin
  def unassigned_students 
    @students = Student.where(:school_id => params[:id], :sektion_id => nil).order(:first_name)
    @who_wants_to_know = current_account.nil? ? :guest : current_account.role
  end 
=end

  def upload_student_list
    @school = School.find params[:id]

    sektion = @school.sektions.build :klass => params[:excel][:klass].to_i, :name => params[:excel][:sektion]
    if sektion.save
      @school.xls = params[:excel][:xls]
      @school.save
      sektion.save # trigger student_roster_pdf generation
      render json: { status: :uploaded }, status: :ok
    else
      render json: { status: :failed }, status: :bad_request
    end
  end

end
