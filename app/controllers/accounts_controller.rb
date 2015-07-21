class AccountsController < ApplicationController
  include GeneralQueries
  before_filter :authenticate_account!, :except => [:ask_question, :reset_password]
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
    render json: { notify: {text: msg} }, status: :ok
  end 

  def reset_password
    e = params[:account][:email]
    unless e.blank?
      @a = Account.where(email: e).first
      @pw = @a.nil? ? nil : @a.reset_password
      unless @pw.nil?
        Mailbot.delay.password_reset(@a, @pw) unless @pw.nil?
        render json: { notify: { title: 'Password updated', 
                                 msg: 'Please check your e-mail for the new password.' } }, status: :ok 
      else
        render json: { notify: { title: 'Invalid E-mail?',
                                 msg: 'We do not have this e-mail in our records. Please try again.' } }, status: :ok 
      end
    end # client side validation should preclude the case with blank e-mail.
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
    eid = params[:id].to_i
    e = Exam.find eid
    
    if @sandboxed 
      # Only publishable exams are considered for sandboxing. 
      # And for a given exam, pick 5 random samples of each question
      @indices = QSelection.where(quiz_id: e.quiz_id).order(:index)
      @last_pg = nil
    else 
      by = current_account.loggable_id
      @pending = Tryout.in_exam(eid).with_scan.ungraded.assigned_to(by)
      sel = @pending.map(&:q_selection_id).uniq
      @indices = QSelection.where(id: sel).order(:index)
      n = @indices.count
      per_pg, @last_pg = pagination_layout_details(n,10)
      pg = params[:page].nil? ? 1 : params[:page].to_i
      @indices = @indices.page(pg).per(per_pg)
    end
  end

  def pending_scans
    # Given: The question and the exam 
    # Known: The examiner who needs to grade them

    eid = params[:e]
    q = QSelection.find(params[:q]).question
    @comments = q.comments 

    exid = current_account.loggable_id
    @sandboxed = !current_account.live?

    # { pending: [{ scan: a, student: b, gr: [{ id: 12, name: "Q6.A" }, {id: 13, name: "Q6.B"}]}, { scan: b ... } ] }
    candidates = Tryout.in_exam(eid).where(q_selection_id: params[:q]).with_scan
    p = @sandboxed ? candidates.limit(5) : candidates.ungraded.assigned_to(exid)

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
      @gr = Tryout.in_exam(@ws_id).ungraded.with_scan
      @gr = ( who == 'Examiner' ) ? @gr.assigned_to(current_account.loggable_id) : @gr 
      @gr = @gr.on_page(page)
    end

    @gr = @gr.sort{ |m,n| m.index? <=> n.index? }
    @students = Student.where(id: @gr.map(&:student_id).uniq)
    @scans = @gr.map(&:scan).uniq
    @quiz = Exam.where(id: @ws_id).map(&:quiz_id).first
  end

  def poll_delayed_job_queue
    qids = params[:quizzes].blank? ? [] : params[:quizzes].map(&:to_i)
    eids = params[:exams].blank? ? [] : params[:exams].map(&:to_i)
    wids = params[:worksheets].blank? ? [] : params[:worksheets].map(&:to_i)

    @q = Quiz.where(id: qids).select{ |m| m.compiled? } 
    @e = Exam.where(id: eids, takehome: false).select{ |m| m.compiled? }
    @w = Worksheet.where(id: wids).select{ |m| m.compiled? }
    user = current_account.loggable 
    @indie = user.respond_to?(:indie) ? user.indie : false
  end 

  def by_country
    type = params[:type].humanize
    @accounts = Account.where(loggable_type: type)
    @countries = Watan.where(id: @accounts.map(&:country).uniq)
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
        render json: { notify: { title: "Got it!", 
                                       msg: 'We will answer your question within 24 hours. Thank you for writing' } }, 
                                       status: :ok
      else
        render json: { notify: { title: "Blank question?", 
                                       msg: 'You seem to have asked nothing' }}, 
                                       status: :ok
      end
    else
      render json: { notify: { title: "Missing E-mail", 
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
