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

  def testpapers
    s = current_account.loggable
    @publishable = Testpaper.where(:id => s.testpaper_ids).where(:publishable => true)
  end

  def responses
    student = Student.find params[:id]
    testpaper = Testpaper.find params[:testpaper]
    head :bad_request if (student.nil? || testpaper.nil?)

    quiz_id = testpaper.quiz_id 

    answers = student.responses testpaper
    @info = answers.map{ |m| { :question => { 
      :id => m.id,
      :name => m.name?,
      :ticker => "#{m.marks?} / #{m.subpart.marks}",
      :pg => "#{m.subpart.on_page_in? quiz_id}"
    } } }

    @scans = answers.map(&:scan).uniq.sort
    @within = "#{quiz_id}-#{testpaper.id}"
    respond_with @info, @scans, @within
  end

end
