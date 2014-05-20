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
        sign_in student.account
        redirect_to student_path
      end # no reason for else.. if client side validations worked
    else # registration data probably entered by a bot
      render json: { notify: { text: "Bot?" } }, status: :bad_request
    end
  end # of method 

  def claim
    # Before execution gets here, client side validation would have ensured that 
    #    1. aid != nil 
    #    2. No account with email that the user has now specified exists from before

    aid = params[:checked].keys.first
    if aid.blank? # client side validation should ensure this never happens
      render json: { notify: { title: "No account specified for merging" } }, status: :ok
    else
      account = Account.find aid
    end

    uinp = params[:account]
    location = request.location
    city = state = country = zip = nil

    unless location.nil?
       city = location.city
       state = location.state
       zip = location.postal_code
       country = Country.where{ name =~ location.country }.first
       country = country.id unless country.blank?
    end
 
    updated = account.update_attributes email: uinp[:email],
                              password: uinp[:password], password_confirmation: uinp[:password],
                              city: city, state: state, postal_code: zip, country: country 

    if updated 
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

  def dispute 
    g = GradedResponse.find params[:id]
    unless g.nil?
      reason = params[:dispute][:reason]
      unless reason.blank?
        r = reason.gsub("\r\n", " ").strip # remove carriage returns
        d = current_account.loggable.disputes.build(graded_response_id: g.id, text: r)
      else
        d = nil
      end 
      unless d.nil?
        d.save
        g.update_attribute(:disputed, true) 
      end
    end
    render json: { status: :ok }, status: :ok
  end 

  def self_subscribe_to_quiz
    sid = current_account.loggable_id
    q = Quiz.find params[:id]
    w = q.assign_to sid
    render json: { w: w.id, q: q.id, e: w.exam.id }, status: :ok
  end 

  def pay_to_grade
    w = Worksheet.find params[:id] 
    unless w.nil?
      w.bill
      render json: { w: w.id }, status: :ok
    else
      render json: { status: :failed }, status: :ok
    end
  end

end
