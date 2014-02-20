class AccountsController < ApplicationController
  before_filter :authenticate_account!, :except => :ask_question
  respond_to :json

  def update 
    email_updated = passwd_updated = nil
    details = params[:updated]

    unless details[:email].blank?
      email_updated |= (current_account.update_attribute :email, details[:email])
    end

    # Ref: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
    unless details[:password].blank?
      unless details[:password_confirmation].blank?
        passwd_updated |= (current_account.update_attributes(
            password: details[:password], 
            password_confirmation: details[:password_confirmation]))

        sign_in current_account, bypass: true if passwd_updated 
      end
    end

    if email_updated == true
      msg = passwd_updated ? "E-mail and password updated" : "E-mail updated"
    elsif passwd_updated == true
      msg = "Password updated"
    else
      msg = "Nothing updated"
    end
    render :json => { :notify => {:text => msg} }, :status => :ok
  end 

  def merge
    # Merges the passed account into current_account, and then deletes the passed loggable obj
    target_id = params[:checked].keys.first
    if target_id.blank?
      render :json => { :notify => { :title => "No account specified for merging" } }, :status => :ok
    else
      source = Account.find target_id
      merged = Account.merge current_account, source
      render :json => { :success => merged }, :status => :ok
    end
  end

  def exams 
    @exams = current_account.exams
    @who = current_account.loggable_type
    @exams = @exams.sort{ |m,n| m.closed_on? <=> n.closed_on? }.reverse
  end

  def courses
    @courses = current_account.courses
  end 

  def pending_exams
    @exams = current_account.pending_exams
    @sandboxed = !current_account.live?
  end

  def to_be_graded
    @sandboxed = !current_account.live?
    eid = params[:id]
    
    if @sandboxed 
      # Only publishable exams are considered for sandboxing. 
      # And for a given exam, pick 5 random samples of each question
      qid = Exam.find(eid).quiz
      @indices = QSelection.where(quiz_id: qid).order(:index)
    else 
      by = current_account.loggable_id
      @pending = GradedResponse.in_exam(eid).with_scan.ungraded.assigned_to(by)
      sel = @pending.map(&:q_selection_id).uniq
      @indices = QSelection.where(id: sel).order(:index)
    end
  end

  def pending_scans
    # Given: The question and the exam 
    # Known: The examiner who needs to grade them

    eid = params[:tp]
    q = params[:q]
    exid = current_account.loggable_id
    @sandboxed = !current_account.live?

    # { pending: [{ scan: a, student: b, gr: [{ id: 12, name: "Q6.A" }, {id: 13, name: "Q6.B"}]}, { scan: b ... } ] }

    qsel = QSelection.find q
    @comments = qsel.germane_comments 
    candidates = GradedResponse.in_exam(eid).where(q_selection_id: q).with_scan

    if @sandboxed
      p = candidates.limit(5) 
    else
      p = candidates.ungraded.assigned_to(exid)
    end
    @pending = p.order(:student_id).order(:subpart_id)
    @students = Student.where(id: @pending.map(&:student_id).uniq)
    @scans = @pending.map(&:scan).uniq
  end 

  def pending_gr
    @ws_id = params[:ws].to_i
    page = params[:page].to_i
    who = current_account.loggable_type
    @gr = []

    if (who == "Teacher" || who == "Examiner")
      @gr = GradedResponse.in_exam(@ws_id).ungraded.with_scan
      @gr = ( who == 'Examiner' ) ? @gr.assigned_to(current_account.loggable_id) : @gr 
      @gr = @gr.on_page(page)
    end

    @gr = @gr.sort{ |m,n| m.index? <=> n.index? }
    @students = Student.where(id: @gr.map(&:student_id).uniq)
    @scans = @gr.map(&:scan).uniq
    @quiz = Exam.where(id: @ws_id).map(&:quiz_id).first
  end

  def submit_fdb
    sandboxed = !current_account.live?
    gid = params[:id].to_i

    db_obj = sandboxed ? current_account.loggable.doodles.build(graded_response_id: gid) : GradedResponse.find(gid)
    ids = params[:checked].keys.map(&:to_i)

    db_obj.fdb(ids) # will either update GradedResponse obj or add a new Doodle

    overlay = params[:overlay].split("@d@").select{ |m| !m.blank? }
    n = 0
    z = overlay.slice(n,3)

    while !z.blank?
      tx = TexComment.where(text: z[2]).first
      if tx.nil?
        tx = TexComment.new examiner_id: current_account.loggable_id, text: z[2]
        tx.save
      end

      rmrk = tx.remarks.create x: z[0], y: z[1], graded_response_id: gid 
      rmrk.update_attributes(doodle_id: db_obj.id) if sandboxed

      n += 3
      z = overlay.slice(n,3)
    end
    render json: { status: :ok }, status: :ok
  end

  def view_fdb
    gid = params[:id].to_i
    @gr = GradedResponse.find gid
    sandboxed = params[:sandbox]

    if sandboxed 
      doodle = Doodle.where(examiner_id: params[:a], graded_response_id: gid).first
      @fdb = Requirement.unmangle_feedback doodle.feedback
    else
      @fdb = Requirement.unmangle_feedback @gr.feedback
    end

    @solution_video = @gr.subpart.question.video

    unless (@fdb.nil? || @fdb == 0) # => none so far 
      if sandboxed 
        @comments = Remark.where(doodle_id: doodle.id)
      else 
        siblings = GradedResponse.where(scan: @gr.scan).map(&:id)
        @comments = Remark.where(graded_response_id: siblings) 
      end 
    end
  end

  def poll_delayed_job_queue
    quiz_ids = params[:quizzes].blank? ? [] : params[:quizzes].map(&:to_i)
    eids = params[:exams].blank? ? [] : params[:exams].map(&:to_i)

    @q = Quiz.where(id: quiz_ids).select{ |m| m.compiled? } 
    @e = Exam.where(id: eids, takehome: false).select{ |m| m.compiled? }
    # @demos = Quiz.where(teacher_id: current_account.loggable_id, parent_id: PREFAB_QUIZ_IDS).where('uid IS NOT ?', nil).select{ |m| m.compiled? }
  end 

  def by_country
    type = params[:type].humanize
    @accounts = Account.where(loggable_type: type)
    @countries = Country.where(id: @accounts.map(&:country).uniq)
  end

  def in_country
    @type = params[:type].humanize
    country_id = params[:country].to_i
    @accounts = Account.where(:loggable_type => @type).where(:country => country_id)
  end

  def ask_question
    unless current_account.nil?
      unless params[:new][:question].blank?
        Mailbot.delay.ask_question(current_account, params[:new][:question])
        render :json => { :notify => { :title => "Got it!", 
                                       msg: 'We will answer your question within 24 hours. Thank you for writing' } }, 
                                       status: :ok
      else
        render :json => { :notify => { :title => "Blank question?", 
                                       msg: 'You seem to have asked nothing' }}, 
                                       status: :ok
      end
    else
      render :json => { :notify => { :title => "Missing E-mail", 
                                     msg: 'Need an e-mail address to reply to' }}, 
                                     status: :ok
    end
  end

  def audit_apprentice
    @apprentice = Examiner.find params[:id]

    unless @apprentice.nil?
      audit = params[:audit]
      @gating = audit[:gating].select{ |m| !m.blank? }
      @nongating = audit[:non_gating].select{ |m| !m.blank? }
      @comment = audit[:comments]

      if @gating.count > 0 
        @apprentice.update_attribute(:live, false)
        @bottomline = "Mentor needs to see more grading samples"
      else 
        @apprentice.update_attribute(:live, true)
        @bottomline = "You are now live and will receive real grading work"
      end 
      Mailbot.delay.inform_apprentice(@apprentice, @bottomline, @gating, @nongating, @comments)
    end
    render json: { status: :ok }, status: :ok
  end

end
