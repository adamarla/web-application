class ExaminersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:distribute_scans, :receive_single_scan, :aggregate]
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
    Delayed::Job.enqueue RotateScan.new(scan_in_locker), priority: 5, run_at: Time.zone.now
    render :json => { :status => "Sent for rotating"}, :status => :ok
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
      images = manifest[:image]
      if images.nil?
        @scans = []
      else 
        #http://stackoverflow.com/questions/13463398/issue-with-a-collection-of-response-elements-using-savon
        unless images.is_a? Array
          images = Array.new << images
        end
        @scans = images.map{ |m| m[:id] }
      end
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
    ret = true
    path = params[:path]
    qrc = params[:id]
    mobile = params[:type] == "GR" 
    old_style = mobile ? false : (qrc.length == 11)

    if mobile
      ids = qrc.split('-').map(&:to_i)
      g = GradedResponse.where(id: ids)
    elsif old_style # can be, and should be, deprecated by March 2014
      ws_id = decrypt qrc[0..6]
      rel_index = decrypt qrc[7..9]
      page = qrc[10].to_i(36)
      student_id = Worksheet.where(exam_id: ws_id).map(&:student_id).sort[rel_index]
      g = GradedResponse.in_exam(ws_id).of_student(student_id).on_page(page)
    else
      ids = Worksheet.unmangle_qrcode qrc
      g = GradedResponse.where(id: ids)
    end

    # A scan, one received, cannot be overwritten with a subsequently uploaded scan 
    already = g.map(&:scan).select{ |x| !x.nil? }.count > 0
    unless already
      g.map{ |x| x.update_attributes scan: path, mobile: mobile } 

      # Sometimes, the scans come in batches. And if the new ones come 
      # after the old ones have been graded, then a mail is triggered 
      # with each new student's work being graded. To avoid this, we 
      # simply reset the exam to its initial unpublished state and leave 
      # it to the grading process to set it back to publishable state
      exam = g.first.worksheet.exam
      exam.update_attribute :publishable, false
    end
    render json: { status: ( already ? 'not ok' : 'ok' ) }
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

  def aggregate
    # Right now it aggregates by teacher_id, can do by others in future - 01/24/14
    AggrByTopic.build(GradedResponse.graded)
    render json: { status: :ok}
  end

end
