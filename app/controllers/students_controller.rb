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
    if @student.save
      respond_with(@student) 
    else 
      head(:bad_request)  
    end
  end 

  def proficiency
    student = Student.find params[:id]
    teacher = current_account.nil? ? nil : (current_account.loggable_type == "Teacher" ? current_account.loggable : nil)
    @json = student.proficiency teacher
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

  def inbox
    student = Student.find params[:id]
    @ws = student.nil? ? [] : student.testpapers
    unless @ws.empty?
      @ws = @ws.where(:inboxed => true)
      open = AnswerSheet.where(:student_id => student.id, :testpaper_id => @ws.map(&:id)).select{ |m| m.received? :none }
      @ws = Testpaper.where :id => open.map(&:testpaper_id)
    else
      render :json => { :notify => { :text => "No new worksheets" }}, :status => :ok
    end
  end 

  def inbox_echo
    @ws = Testpaper.find params[:ws]
    @quiz = @ws.quiz
    @student = current_account.loggable
    unless @ws.nil? 
      AnswerSheet.where(:testpaper_id => @ws.id, :student_id => @student.id).first.compile_tex
    end
  end

  def outbox
  end

end
