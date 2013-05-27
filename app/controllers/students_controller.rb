class StudentsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def show
    render :nothing => true, :layout => 'students'
  end

  def create 
    data = params[:student]

    if data[:guard].blank? # => human entered registration data
      student = Student.new :name => data[:name]

      location = request.location
      city = state = country = zip = nil

      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = Country.where{ name =~ location.country }.first
         country = country.id unless country.blank?
      end

      account_details = data[:account]
      account = student.build_account :email => account_details[:email], 
                                      :password => account_details[:password],
                                      :password_confirmation => account_details[:password],
                                      :city => city,
                                      :state => state, 
                                      :postal_code => zip,
                                      :country => country
      if student.save
        Mailbot.welcome_student(student.account).deliver
        sign_in student.account
        redirect_to student_path
      end # no reason for else.. if client side validations worked
    else # registration data probably entered by a bot
      render :json => { :notify => { :text => "Bot?" } }, :status => :bad_request
    end
  end # of method 

  def enroll 
    code = params[:enroll][:sektion]
    sk = Sektion.where{ uid =~ "#{code}" }.first

    if sk.nil?
      render :json => { :notify => { :text => "Group not found!", 
                        :subtext => "Re-check the code you entered" } }, :status => :ok
    else
      student = current_account.loggable
      enrolled = sk.students 

      similarly_named = enrolled.select{ |m| Levenshtein.distance(m.name, student.name) < 5 }
      @candidates = similarly_named.select{ |m| !m.account.email_is_real? } 
    end # else

  end # method

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
