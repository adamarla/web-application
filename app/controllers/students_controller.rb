class StudentsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def show
    render :nothing => true, :layout => 'students'
  end

  def create 
    info = params[:register]
    student = Student.new :name => info[:name]
    username = create_username_for student, :student 
    account = student.build_account :email => info[:email], :password => info[:password],
                                    :password_confirmation => info[:password], :trial => false,
                                    :username => username
    if student.save 
      enroll_in = Sektion.where{ uid =~ info[:code] }.first
      enroll_in.students << student unless enroll_in.nil?
      render :json => { :notify => { :text => "Registration Successful" }}, :status => :ok
    else
      render :json => { :notify => { :text => "Registration Failed" }}, :status => :ok
    end
  end 

  def enroll 
    code = params[:enroll][:sektion]
    sid = params[:id]
    student = sid.blank? ? current_account.loggable : Student.where(:id => sid).first

    unless code.blank?
      sk = Sektion.where{ uid =~ "#{code}" }.first
      unless sk.nil?
        sk.students << student unless student.nil?
        render :json => { :notify => { :text => "Successfully enrolled in '#{sk.name}'" }}, :status => :ok 
      else
        render :json => { :notify => { :text => "No section with code '#{code}' found" }}, :status => :ok 
      end
    else
      render :json => { :notify => { :text => "Enrollment failed", :subtext => "No section code provided" }}, :status => :ok
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
