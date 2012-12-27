class ExaminersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:update_workset]
  respond_to :json

  def create 
    added = true
    params[:examiners].each_value do |v,index|
      name = v[:name]
      as_admin = v[:admin].blank? ? false : true

      next if name.blank?
      #puts "#{name} --> #{as_admin}"

      examiner = Examiner.new :name => name, :is_admin => as_admin
      username = create_username_for examiner, (as_admin ? :admin : :examiner)
      email = "#{username}@drona.com" # default. Can be changed later by the examiner
      account = examiner.build_account :email => email, :username => username, 
                                       :password => "123456", :password_confirmation => "123456"
      added &= examiner.save
      break if !added 
    end
    added ? head(:ok) : head(:bad_request)
  end 

  def show
    render :nothing => true, :layout => 'examiner'
  end

  def list 
    @examiners = Examiner.order(:last_name)
  end 

  def pending_quizzes
    examiner = Examiner.where(:id => current_account.loggable_id).first
    head :bad_request if examiner.nil?
    @quizzes = examiner.pending_quizzes 
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    slots = examiner.block_db_slots
    render :json => {:slots => slots}, :status => :ok
  end

  def update_workset
    failures = Examiner.receive_scans
    render :json => failures, :status => :ok
  end

  def rotate_scan
    scan_in_locker = params[:id]
    Delayed::Job.enqueue RotateScan.new(scan_in_locker), :priority => 5, :run_at => Time.zone.now
    render :json => { :status => "Sent for rotating"}, :status => :ok
  end

  def restore_pristine_scan
    scan_in_locker = params[:id]
    Delayed::Job.enqueue RestorePristineScan.new(scan_in_locker), :priority => 5, :run_at => Time.zone.now
    render :json => { :status => "Restoring"}, :status => :ok
  end

  def suggestions
    examiner = params[:id].blank? ? current_account.loggable : Examiner.find(params[:id])
    unless examiner.nil?
      @all = examiner.suggestions 
      @wips = @all.wip
      @just_in = @all.just_in
      @completed = @all.completed
    else
      @all = @wips = @just_in = @completed = []
    end
  end # of method

=begin
  Actions pertaining to feedback
=end
  def feedback 
    type = params[:type]
    scale = Rubric[type] 
    start = rubric_first_of_x_at type 
    @delineated = []
    scale.each { |k,v| @delineated.push({ :b => { :name => v['text'], :id => "#{start + k}" } }) unless v['text'].blank? }
    
    # delineated is something that we pass to RABL and it renders it as-is 
    # But we ensure it has the form expected by line-item.js
  end 


end
