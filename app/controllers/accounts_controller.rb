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

  def ws 
    @wks = current_account.ws
    @who = current_account.loggable_type
    @wks = @wks.sort{ |m,n| m.closed_on? <=> n.closed_on? }.reverse if @who == "Student"
  end

  def courses
    @courses = current_account.courses
  end 

  def pending_ws
    @wks = current_account.pending_ws
  end

  def to_be_graded
    tid = params[:id]
    by = current_account.loggable_id
    @pending = GradedResponse.in_exam(tid).with_scan.ungraded.assigned_to(by)
    sel = @pending.map(&:q_selection_id).uniq
    @indices = QSelection.where(id: sel).order(:index)
  end

  def pending_scans
    # Given: The question and the exam 
    # Known: The examiner who needs to grade them

    tp = params[:tp]
    q = params[:q]
    eid = current_account.loggable_id

    # { pending: [{ scan: a, student: b, gr: [{ id: 12, name: "Q6.A" }, {id: 13, name: "Q6.B"}]}, { scan: b ... } ] }

    p = GradedResponse.in_exam(tp).where(q_selection_id: q).with_scan.ungraded.assigned_to(eid)
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
    r = GradedResponse.find(params[:id].to_i)
    ids = params[:checked].keys.map(&:to_i)
    r.fdb ids
    overlay = params[:overlay].split("@d@").select{ |m| !m.blank? }
    n = 0
    z = overlay.slice(n,3)

    while !z.blank?
      r.tex_comments.create x: z[0], y:z[1], tex: z[2]
      n += 3
      z = overlay.slice(n,3)
    end
    render :json => { :status => :ok }, :status => :ok
  end

  def view_fdb
    @gr = GradedResponse.find(params[:id])
    @fdb = Requirement.unmangle_feedback @gr.feedback
    @solution_video = @gr.subpart.question.video

    unless (@fdb.nil? || @fdb == 0) # => none so far 
      @comments = TexComment.where(graded_response_id: @gr.id)
    end
  end

  def poll_delayed_job_queue
    quiz_ids = params[:quizzes].blank? ? [] : params[:quizzes].map(&:to_i)
    eids = params[:exams].blank? ? [] : params[:exams].map(&:to_i)

    @quizzes = Quiz.where(id: quiz_ids).select{ |m| !m.compiling? }
    @ws = Exam.where(id: eids).select{ |m| !m.compiling? }
    @demo = @ws.select{ |m| PREFAB_QUIZ_IDS.include? m.quiz.parent_id }
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

end
