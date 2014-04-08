class ExaminersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, except: [:distribute_scans, :receive_single_scan, :aggregate, :daily_digest]
  respond_to :json

  def create
    p = params[:examiner]

    unless current_account.nil?
      is_teacher = current_account.loggable_type == 'Teacher'
      is_admin = is_teacher ? false : (current_account.loggable.respond_to?(:is_admin) ? current_account.loggable.is_admin : false)
    else
      is_teacher = false 
      is_admin = false
    end
    all_good = true

    p.keys.each do |k| 
      d = p[k]
      next if ( d["name"].blank? || d["email"].blank? )
      mentor = is_teacher ? current_account.loggable_id : Examiner.experienced.select{ |e| e.live? }.sample(1).first.id
      e = Examiner.new(name: d[:name], live: is_teacher, mentor_id: mentor, mentor_is_teacher: is_teacher, internal: is_admin)
      a = e.build_account(email: d[:email], password: '123456', password_confirmation: '123456')
      all_good &= e.save
    end 

    if all_good 
      render json: { status: 'Success' }, status: :ok
    else
      render json: { status: 'Failed' }, status: :ok
    end
  end

  def show
    render nothing: true, layout: 'admin-examiner'
  end

  def list 
    @examiners = Examiner.order(:last_name)
  end 

  def apprentices 
    type = params[:type]

    if type.blank? 
      live = false 
      dead = true 
      any = false 
    else 
      live = type == 'live' 
      dead = type == 'dead' 
      any = type == 'any'
    end 

    @apprentices = current_account.loggable.apprentices  # should be all Examiners only
    @apprentices = live ? @apprentices.select{ |a| a.live? } : ( dead ? @apprentices.select{ |a| !a.live? } : @apprentices )
  end 

  def load_samples
    @apprentice = params[:id].to_i
    doodles = Doodle.where(examiner_id: @apprentice)
    @gids = doodles.map(&:graded_response_id).uniq 
  end

  def untagged
    @questions = Question.author(current_account.loggable_id).untagged
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    slots = examiner.block_db_slots
    render json: {notify: { text: "6 slots blocked", :subtext => "Do 'git fetch origin/master'"} }, status: :ok
  end

  def distribute_scans
    ws_ids = Examiner.distribute_scans
    render json: ws_ids, status: :ok
  end

  def rotate_scan
    scan_in_locker = params[:id]
    Delayed::Job.enqueue RotateScan.new(scan_in_locker), priority: 5, run_at: Time.zone.now
    render json: { status: "Sent for rotating"}, status: :ok
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
    render json: { status: status }, status: :ok
  end

  def receive_single_scan
    ret = true
    path = params[:path]
    qrc = params[:id]
    mobile = params[:type] == "GR" 
    old_style = mobile ? false : (qrc.length == 11)

    puts "========debugging params #{path} #{qrc} #{params[:type]} ==========="

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

    # Do NOT receive scan under the following conditions 
    #   1. if the graded responses already have an associated scan 
    #   2. if its past the submission deadline 

    exam = g.first.worksheet.exam
    if exam.receptive? 
      j = g.without_scan
      proceed = mobile ? true : (j.count == 0) # all or nothing if !mobile
      if proceed
        puts "============ got here ======#{path}===="
        j.map{ |x| x.update_attributes(scan: path, mobile: mobile) }
        exam.update_attribute :publishable, false
        # Sometimes, the scans come in batches. And if the new ones come 
        # after the old ones have been graded, then a mail is triggered 
        # with each new student's work being graded. To avoid this, we 
        # simply reset the exam to its initial unpublished state and leave 
        # it to the grading process to set it back to publishable state
      end
    end
    render json: { status: :ok }, status: :ok 
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

  def germane_comments
    g = GradedResponse.find params[:g]
    unless g.nil?
      @comments = g.q_selection.germane_comments
    else
      render json: { comments: [] }, status: :ok
    end
  end

  def aggregate
    # Right now it aggregates by teacher_id, can do by others in future - 01/24/14
    AggrByTopic.build(GradedResponse.graded)
    render json: { status: :ok}
  end

  def load_dispute 
    @g = GradedResponse.find params[:id]
    @comments = @g.nil? ? nil : Remark.where(graded_response_id: @g.id)
  end 

  def disputed 
    @g = GradedResponse.assigned_to(current_account.loggable_id).with_scan.unresolved
  end 

  def reject_dispute
    g = GradedResponse.find params[:id]
    unless g.nil?
      g.update_attribute :resolved, true
      render json: { disabled: g.id }, status: :ok
    else
      render json: { status: :ok }, status: :ok
    end 
  end 

  def accept_dispute
    g = GradedResponse.find params[:id]
    unless g.nil?
      g.reset false
      render json: { disabled: g.id }, status: :ok
    else
      render json: { status: :ok }, status: :ok
    end 
  end 

  def daily_digest  
    g = GradedResponse.with_scan
    ug = g.ungraded # ug = ungraded 
    d = g.unresolved # d = disputes 
    e = Examiner.available

    for j in e
      next unless j.account.email_is_real?
      a = ug.where(examiner_id: j.id).count > 0
      b = d.where(examiner_id: j.id).count > 0
      if a || b 
        j.mail_daily_digest a,b
      end 
    end
    render json: { status: :ok }, status: :ok
  end 

  def load_dispute_reason
    d = Dispute.where(graded_response_id: params[:id]).first
    reason = (d.nil? || d.text.blank?) ? "No reason provided" : d.text
    render json: { notify: { msg: reason } }, status: :ok
  end

end
