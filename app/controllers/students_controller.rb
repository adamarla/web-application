class StudentsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create, :match, :claim]
  respond_to :json

  def show
    render nothing: true, layout: 'students'
  end

  def create 
    data = params[:student]

    if data[:guard].blank? # => human entered registration data
      student = Student.new name: data[:name]

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
      account = student.build_account email: account_details[:email], 
                                      password: account_details[:password],
                                      password_confirmation: account_details[:password],
                                      city: city,
                                      state: state, 
                                      postal_code: zip,
                                      country: country
      if student.save
        # Mailbot.delay.welcome_student(student.account)
        sign_in student.account
        redirect_to student_path
      end # no reason for else.. if client side validations worked
    else # registration data probably entered by a bot
      render json: { notify: { text: "Bot?" } }, status: :bad_request
    end
  end # of method 

  def claim
    target_id = params[:checked].keys.first
    if target_id.blank?
      render json: { notify: { title: "No account specified for merging" } }, status: :ok
    else
      account = Account.find target_id
    end

    account_details = params[:account]
    location = request.location
    city = state = country = zip = nil

    unless location.nil?
       city = location.city
       state = location.state
       zip = location.postal_code
       country = Country.where{ name =~ location.country }.first
       country = country.id unless country.blank?
    end
 
    account.update_attributes email: account_details[:email],
                              password: account_details[:password],
                              password_confirmation: account_details[:password],
                              city: city,
                              state: state,
                              postal_code: zip,
                              country: country 

    if account.save
      Mailbot.delay.welcome(account)
      sign_in account
      redirect_to student_path
    end # no reason for else.. if client side validations worked
  end

  def match
    data = params[:student]
    student = Student.new name: data[:name]
    sk = Sektion.where{ uid =~ "#{data[:code]}" }.first

    @exists = true
    @enrolled = false
    @candidates = []

    if sk.nil?
      @exists = false
    else
      unmatched = sk.students.select{ |s| !s.account.email_is_real? }
      @candidates = unmatched.select{ |s| Student.min_levenshtein_distance(s.name, student.name) < 3 }
    end # else

  end # method

  def enroll 
    code = params[:enroll][:sektion]
    sk = Sektion.where{ uid =~ "#{code}" }.first

    @exists = true
    @enrolled = false
    @candidates = []

    if sk.nil?
      @exists = false
    elsif sk.student_ids.include? current_account.loggable_id
      @enrolled = true
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

  def inbox
    sid = params[:id]
    student = Student.find sid
    hw = student.nil? ? [] : Worksheet.where(student_id: sid, exam_id: Exam.takehome.map(&:id))
    open = hw.select{ |h| h.received? :none }

    unless open.blank?
      @exams = Exam.where(id: open.map(&:exam_id).uniq)
    else
      render(json: { notify: { text: 'No new worksheets' }}, status: :ok) if @exams.blank?
    end
  end 

  def inbox_echo
    eid = params[:e]
    sid = current_account.loggable_id

    w = Worksheet.where(student_id: sid, exam_id: eid).first 
    unless w.nil?
      render json: { a: "mint/#{w.path?}" }, status: :ok
    else
      render json: { status: 'No worksheet found' }, status: :bad_request 
    end
  end

  def outbox
  end

end
