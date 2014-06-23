class StudentsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def show
    render nothing: true, layout: 'students'
  end

  def create 
    d = params[:student]

    if d[:jaal].blank? # => human entered registration data
      student = Student.new name: d[:name]

      location = request.location
      city = state = country = zip = nil

      unless location.nil?
         city = location.city
         state = location.state
         zip = location.postal_code
         country = Country.where{ name =~ location.country }.first
         country = country.id unless country.blank?
      end

      login = d[:account_attributes]
      account = student.build_account email: login[:email], 
                                      password: login[:password],
                                      password_confirmation: login[:password],
                                      city: city,
                                      state: state, 
                                      postal_code: zip,
                                      country: country
      if student.save
        Mailbot.delay.welcome(account)
        sign_in account
        redirect_to student_path
      end # no reason for else.. if client side validations worked
    else # registration data probably entered by a bot
      render json: { notify: { text: "Bot?" } }, status: :bad_request
    end
  end # of method 

  def match
    sk = Sektion.where(uid: "#{params[:enroll][:sektion]}".upcase).first 
    nm = current_account.loggable.name

    @exists = true
    @enrolled = false
    @candidates = []

    if sk.nil?
      @exists = false
    else
      unmatched = sk.students.select{ |s| !s.account.has_email? }
      @candidates = unmatched.select{ |s| Student.min_levenshtein_distance(s.name, nm) < 3 }
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
    g = Attempt.find params[:id]
    unless g.nil?
      reason = params[:dispute][:reason]
      unless reason.blank?
        r = reason.gsub("\r\n", " ").strip # remove carriage returns
        d = current_account.loggable.disputes.build(attempt_id: g.id, text: r)
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


end
