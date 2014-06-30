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

  def inbox 
    # published with ** no scans **  
    all = Worksheet.where(student_id: current_account.loggable_id)
    @inboxed = all.select{ |j| !j.billed || ( j.billed && j.received?(:none) )} 
  end 

  def outbox
    # some/all scans received - not graded 
    all = Worksheet.where(student_id: current_account.loggable_id, billed: true)
    some_scans = all.select{ |j| !j.received?(:none) } 
    @outboxed = some_scans.select{ |j| j.attempts.graded.count == 0 } 
  end

  def match
    sk = Sektion.where(uid: "#{params[:enroll][:sektion]}".upcase).first 
    @exists = true
    @enrolled = false
    @candidates = []

    if sk.nil?
      @exists = false
    else
      enrolled = sk.students
      @already = enrolled.map(&:id).include? current_account.loggable_id
      unless @already
        unmatched = enrolled.where(shell: true)
        gold = current_account.loggable
        @candidates = unmatched.select{ |s| Student.min_levenshtein_distance(s, gold) < 6 }
      else
        @candidates = []
      end 
    end # else
  end # method

  def merge 
    target_id = params[:checked].keys.first
    unless target_id.blank?
      target = Student.find target_id 
      src = current_account.loggable
      merged = Student.merge target, src
      sign_in current_account, bypass: true if merged 
      render json: { success: merged }, status: :ok
    else 
      render json: { notify: { title: "No account specified for merging" } }, status: :ok
    end 
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
