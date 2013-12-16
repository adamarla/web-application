class ExaminersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:distribute_scans, :update_scan_id]
  respond_to :json

  def create
    p = params[:examiner]

    e = Examiner.new name: p[:name]
    a = e.build_account email: p[:email], password: '123456', password_confirmation: '123456'
    if e.save
      render json: { status: 'Success' }, status: :ok
    else
      render json: { status: 'Failed' }, status: :ok
    end
  end

  def show
    render :nothing => true, :layout => 'admin-examiner'
  end

  def list 
    @examiners = Examiner.order(:last_name)
  end 

  def untagged
    @questions = Question.author(current_account.loggable_id).untagged
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    slots = examiner.block_db_slots
    render :json => {:notify => { :text => "6 slots blocked", :subtext => "Do 'git fetch origin/master'"} }, :status => :ok
  end

  def distribute_scans
    ws_ids = Examiner.distribute_scans
    render :json => ws_ids, :status => :ok
  end

  def rotate_scan
    scan_in_locker = params[:id]
    Delayed::Job.enqueue RotateScan.new(scan_in_locker), :priority => 5, :run_at => Time.zone.now
    render :json => { :status => "Sent for rotating"}, :status => :ok
  end

  def restore_pristine_scan
    scan_in_locker = params[:id]
    Delayed::Job.enqueue RestorePristineScan.new(scan_in_locker), :priority => 5, :run_at => Time.zone.now
    render :json => { :notify => { 
                      :text => "Restored scan", 
                      :subtext => "Don't forget to re-grade all questions on the page" }}, :status => :ok
  end

  def typeset_new
    examiner = current_account.loggable
    @new = examiner.nil? ? [] : Suggestion.assigned_to(examiner.id).just_in
  end # of method

  def typeset_ongoing
    examiner = current_account.loggable
    @ongoing = examiner.nil? ? [] : Suggestion.assigned_to(examiner.id).ongoing
    # @ongoing = Question.where(:id => @ongoing.map(&:question_ids).flatten)
  end # of method

  def unresolved_scans
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['fetch_unresolved_scans']}" 
    response = SavonClient.request :wsdl, :fetchUnresolvedScans do
      soap.body = { 
        :grader => { :id => current_account.loggable_id },
        :maxQuantity => 10
      }
    end
    manifest = response[:fetch_unresolved_scans_response][:manifest]
    unless manifest.blank?
      @root = manifest[:root]
      @scans = manifest[:image].nil? ? [] : manifest[:image].map{ |m| m[:id] }
    else
      @root = nil
      @scans = []
    end
  end

  def preview_unresolved
    file = params[:id]
    render json: { preview: { source: :scantray, images: ["#{file}"] }}, status: :ok
  end

  def resolve_scan
    file = params[:checked].keys.first
    code = params[:code].values.join

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['resolve_scan']}" 
    if code.blank? # delete the scan 
      response = SavonClient.request :wsdl, :resolveScan do 
        soap.body = { :id => file }
      end
      status = :deleted 
    else
      response = SavonClient.request :wsdl, :resolveScan do 
        soap.body = { :id => file, :value => code.upcase }
      end
      status = :renamed
    end
    render :json => { :status => status }, :status => :ok
  end

  def receive_single_scan
    status = "not ok"

    path = params[:path]
    id = params[:id]

    graded_resp = []
    if params[:type] == "QR"
      ws_id = decrypt id[0..6]
      rel_index = decrypt id[7..9]
      page = id[10].to_i(36)
      student_id = AnswerSheet.where(:testpaper_id => ws_id).map(&:student_id).sort[rel_index]
      graded_resp = GradedResponse.in_testpaper(ws_id).of_student(student_id).on_page(page)
    else
      id.split('-').each do |grID|
        graded_resp  << GradedResponse.find_by_id(grID.to_i)
      end
    end

    graded_resp.each do |gr|
      if gr[:scan].nil? 
        gr.update_attribute :scan, path
        if gr.testpaper.publishable? # if fresh scans have arrived
          gr.testpaper.update_attribute :publishable, false
        end
        status = "ok"
      else
        status = "not ok"
        break
      end
    end
    render :json => { :status => status }
  end

  def audit_todo
    unaudited = Question.where(auditor: current_account.loggable_id).unaudited.order(:updated_at)
    
    unless params[:t].blank?
      unaudited = unaudited.reverse_order if params[:t] == 'newest'
    end
    @questions = unaudited.limit 15
  end

  def audit_review
    @questions = Question.where(examiner_id: current_account.loggable_id).where(available: false)
  end 

  def reset_graded 
    g = GradedResponse.find params[:id]
    unless g.nil?
      g.reset false # false => non-soft resetting => associated comments also destroyed
    end
    render json: { status: :ok }, status: :ok 
  end 

end
