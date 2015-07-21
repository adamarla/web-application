class ExaminersController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, 
  except: [:block_db_slots, :distribute_scans, :receive_single_scan, :aggregate, :daily_digest]
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
    render nothing: true, layout: 'ad-ex'
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
    @gids = doodles.map(&:tryout_id).uniq 
  end

  def untagged
    @questions = Question.author(current_account.loggable_id).untagged
  end

  def block_db_slots
    examiner = Examiner.find params[:id]
    unless examiner.nil? 
      slots = examiner.block_db_slots
      render json: { notify: { text: "10 slots blocked" } }, status: :ok 
    else 
      render json: { notify: { text: "No such examiner" } }, status: :ok
    end 
  end

  def distribute_scans
    Examiner.distribute_stabs 
    Examiner.distribute_scans
    render json: { status: :distributed }, status: :ok
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

=begin
               Puzzle    Question    Quiz(takehome)    Quiz(in-class)
               ------    --------    --------------    --------------
type            PZL       QSN         GR                  QR               DBT      SOLN 
id              sbp_ids   sbp_ids     tryout_ids      mangled QR-code     nil      doubt-id  
student_id         +        +            nil              nil               +       nil 
vers               +        nil          nil              nil              nil      nil 
path            ( common to all )

=end

  def receive_single_scan
    ret = true
    path = params[:path]
    type = params[:type]
    g = nil
    sid = params[:student_id].blank? ? nil : params[:student_id].to_i

    if type == 'PZL' || type == 'QSN' # stab at a puzzle or question (mobile only) 
      ids = params[:id].split('-').map(&:to_i) # subpart IDs 
      qid = Subpart.where(id: ids).map(&:question_id).first 
      is_puzzle = (type == 'PZL')
      version = is_puzzle ? 0 : params[:vers].to_i
      uid = Stab.date_to_uid path.split('/').first

      # Check for any existing record and create one if none exists
      stab = Stab.where(student_id: sid, question_id: qid, puzzle: is_puzzle).first
      stab = stab.nil? ? Stab.create(student_id: sid, puzzle: is_puzzle, question_id: qid, uid: uid, version: version) : stab 

      # Now, bind the passed scan to the stab
      stab.add_scan(path) 

    elsif type == 'DBT' # a doubt (mobile only) 
      dbt = Doubt.find params[:id].to_i
      dbt.update_attribute(:scan, path) unless dbt.nil?
    elsif type == 'SOLN' # solution to a doubt 
      dbt = Doubt.find params[:id].to_i
      dbt.update_attribute(:solution, path) unless dbt.nil?
    else # is not a stab
      ids = type == 'GR' ? params[:id].split('-') : Worksheet.unmangle_qrcode(params[:id])
      g = Tryout.where(id: ids)
      mobile = (type == 'GR')

      # Do NOT receive scan under the following conditions 
      #   1. if the tryouts already have an associated scan 
      #   2. if its past the submission deadline 

      exam = g.first.worksheet.exam
      if exam.receptive? 
        j = g.without_scan
        proceed = mobile ? true : (j.count == g.count) # all or nothing if !mobile
        if proceed
          j.map{ |x| x.update_attributes(scan: path, mobile: mobile) }
          exam.update_attribute :publishable, false
          # Sometimes, the scans come in batches. And if the new ones come 
          # after the old ones have been graded, then a mail is triggered 
          # with each new student's work being graded. To avoid this, we 
          # simply reset the exam to its initial unpublished state and leave 
          # it to the grading process to set it back to publishable state
        end # proceed
      end # receptive? 
    end # if not a stab 
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
    g = Tryout.find params[:id]
    unless g.nil?
      g.reset false # false => non-soft resetting => associated comments also destroyed
    end
    render json: { status: :ok }, status: :ok 
  end 

  def germane_comments
    # Even though we have a handle on an Tryout, what we need are 
    # applicable comments and hints for the whole question. The tryout the 
    # examiner is grading now might only be a subpart of a larger question
    a = Tryout.find params[:g]
    q = a.nil? ? nil : a.subpart.question
    @comments = q.nil? ? [] : q.comments 
    render json: { comments: @comments }, status: :ok
  end

  def aggregate
    # Right now it aggregates by teacher_id, can do by others in future - 01/24/14
    AggrByTopic.build(Tryout.graded)
    render json: { status: :ok}
  end

  def load_dispute 
    @g = Tryout.find params[:id]
    @comments = @g.nil? ? nil : Remark.where(tryout_id: @g.id)
  end 

  def disputed 
    @g = Tryout.assigned_to(current_account.loggable_id).with_scan.unresolved
  end 

  def reject_dispute
    a = Tryout.find params[:id]
    unless a.nil?
      a.update_attribute :resolved, true
      Mailbot.delay.reject_dispute a.id, a.examiner_id, params[:reject][:reason]
      render json: { disabled: [a.id] }, status: :ok
    else
      render json: { status: :ok }, status: :ok
    end 
  end 

  def accept_dispute
    g = Tryout.find params[:id]
    unless g.nil?
      g.reset false
      render json: { disabled: [g.id] }, status: :ok
    else
      render json: { status: :ok }, status: :ok
    end 
  end 

  def daily_digest  
    g = Tryout.with_scan
    ug = g.ungraded # ug = ungraded 
    d = g.unresolved # d = disputes 
    e = Examiner.available

    for j in e
      next unless j.account.has_email?
      a = ug.where(examiner_id: j.id).map(&:worksheet).map(&:exam).uniq.select{ |k| k.grade_by? > -15 }.count > 0
      b = d.where(examiner_id: j.id).count > 0
      if a || b 
        j.mail_daily_digest a,b
      end 
    end
    render json: { status: :ok }, status: :ok
  end 

  def load_dispute_reason
    d = Dispute.where(tryout_id: params[:id]).first
    reason = (d.nil? || d.text.blank?) ? "No reason provided" : d.text
    render json: { notify: { msg: reason } }, status: :ok
  end

  def load_rubric
    e = Exam.find params[:e]
    r = Rubric.find e.rubric_id?
    @criteria = r.criteria?
  end 

end
