class StudentsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def show
    render :nothing => true, :layout => 'students'
  end

  def create 
    school = School.find params[:id] 
    head :bad_request if school.nil?
    
    @student = Student.new params[:student]
    username = create_username_for @student, :student 
    email = params[:student].delete(:email) || "#{username}@drona.com"
    @student.school = school 
    password = school.zip_code

    unless username.blank?
      account = @student.build_account :username => username, :email => email,  
                                      :password => password, :password_confirmation => password
    end 
    @student.save ? respond_with(@student) : head(:bad_request)  
  end 

  def dispute
    s_id = current_account.loggable_id
    response = GradedResponse.where(:id => params[:id], :student_id => s_id)
    head :bad_request if response.empty?
    response.first.update_attribute :disputed, true
    render :json => { :status => :ok }, :status => :ok
  end

  def responses
    s = current_account.loggable
    tp = Testpaper.find params[:id]

    r = s.responses params[:id]
    @scans = r.map(&:scan).uniq.sort
    @within = "#{tp.quiz_id}-#{tp.id}"
  end

end
