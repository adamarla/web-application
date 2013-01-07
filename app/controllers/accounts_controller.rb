class AccountsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def update
    account = Account.find params[:id]
    head :bad_request if account.nil?
    done = account.update_attribute :email, params[:account][:email]

    done ? render(:json => {:status => "new e-mail set"}, :status => :ok) : 
           render(:json => {:status => "update failed"}, :status => :bad_request)
  end

  def update_password
    # Ref: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
    account = params[:account]
    failed = current_account.update_attributes(:password => account[:password], 
                                               :password_confirmation => account[:password_confirmation]) ? false : true
    sign_in current_account, :bypass => true unless failed
    failed ? render(:json => {:status => "update failed"}, :status => :bad_request) :
             render(:json => {:status => "new password set"}, :status => :ok) 
  end

  def ws 
    @wks = current_account.ws
  end

  def pending_ws
    @wks = current_account.pending_ws
  end

  def pending_pages
    tid = params[:id]
    who = current_account.loggable_type
    @gr = nil

    if (who == "Teacher" || who == "Examiner")
      @gr = GradedResponse.in_testpaper(tid).ungraded.with_scan
      @gr = ( who == 'Examiner' ) ? @gr.assigned_to(current_account.loggable_id) : @gr 
    else
      @gr = []
    end
    @pages = @gr.map(&:page).uniq.sort
  end

  def pending_gr
    @ws_id = params[:ws].to_i
    page = params[:page].to_i
    who = current_account.loggable_type
    @gr = []

    if (who == "Teacher" || who == "Examiner")
      @gr = GradedResponse.in_testpaper(@ws_id).ungraded.with_scan
      @gr = ( who == 'Examiner' ) ? @gr.assigned_to(current_account.loggable_id) : @gr 
      @gr = @gr.on_page(page)
    end

    @gr = @gr.sort{ |m,n| m.index? <=> n.index? }
    @students = Student.where(:id => @gr.map(&:student_id).uniq)
    @scans = @gr.map(&:scan).uniq
    @quiz = Testpaper.where(:id => @ws_id).map(&:quiz_id).first
  end

  def submit_fdb
    r = GradedResponse.find(params[:id].to_i)
    clicks = GradedResponse.annotations params[:clicks]

    # Generate, then store, the mangled feedback
    ids = params[:checked].keys.map(&:to_i)
    r.fdb ids 
    scan = "#{r.testpaper.quiz_id}-#{r.testpaper_id}/#{r.scan}"
    Delayed::Job.enqueue AnnotateScan.new(scan, clicks), 
      :priority => 10, :run_at => Time.zone.now unless clicks.empty?

    render :json => { :status => :ok }, :status => :ok
  end

  def view_fdb
    gr = GradedResponse.find(params[:id])
    fdb = gr.feedback

    unless (fdb.nil? || fdb == 0) # => none so far 
      fdb = Requirement.unmangle_feedback fdb 
      render :json => { :fdb => fdb }, :status => :ok
    else
      head :bad_request 
    end

  end

end
