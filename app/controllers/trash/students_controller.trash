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

      # Collect Geocoding information from IP request
      lcn = request.location
      gps = {} 
      [:city, :state, :postal_code].each do |k| 
        gps[k] = lcn.nil? ? nil : lcn.send(k)
      end 
      country = lcn.nil? ? nil : Watan.where{ name =~ lcn.country }.first 
      gps[:country] = country.blank? ? nil : country.id 

      login = d[:account_attributes]
      account = student.build_account email: login[:email], 
                                      password: login[:password],
                                      password_confirmation: login[:password]

      # Protected attributes => cannot be mass-assigned => must be individually assigned
      [:city, :state, :postal_code, :country].each do |k| 
        account[k] = gps[k]
      end 

      if student.save
        if d[:mobile].nil?
          sign_in account
          redirect_to student_path
        else
          account.ensure_authentication_token!
          json = {
            :token => account.authentication_token,
            :email => account.email,
            :name  => student.name
          }
          render json: json, status: 200
        end
      end # no reason for else.. if client side validations worked
    else # registration data probably entered by a bot
      render json: { notify: { text: "Bot?" } }, status: :bad_request
    end
  end # of method 

  def inbox 
    # published with ** no scans **  
    s = current_account.loggable
    @inboxed = s.inbox
    @render = params[:ping].blank? 
  end 

  def outbox
    # some/all scans received - not graded 
    all = Worksheet.where(student_id: current_account.loggable_id, billed: true)
    some_scans = all.select{ |j| !j.received?(:none) } 
    @outboxed = some_scans.select{ |j| j.tryouts.graded.count == 0 } 
    @render = params[:ping].blank? 
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
      if merged 
        sign_in current_account, bypass: true 
        redirect_to student_path
      end 
      render json: { success: merged }, status: :ok
    else 
      render json: { notify: { title: "No account specified for merging" } }, status: :ok
    end 
  end 

  def dispute 
    g = Tryout.find params[:id]
    unless g.nil?
      reason = params[:dispute][:reason]
      unless reason.blank?
        r = reason.gsub("\r\n", " ").strip # remove carriage returns
        d = current_account.loggable.disputes.build(tryout_id: g.id, text: r)
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
