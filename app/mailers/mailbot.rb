class Mailbot < ActionMailer::Base
  default from: "mailer-noreply@gradians.com"
  layout 'mailbot'

  def curious_email(teacherform)
    mail subject:  teacherform[:email], 
      body:  teacherform[:text], to:  "akshay@gradians.com"
    mail subject:  teacherform[:email], 
      body:  teacherform[:text], to:  "abhinav@gradians.com"
  end

  def welcome(a)
    @obj = a.loggable
    @type = a.loggable_type
    @self_registered = (@type != 'Examiner') ? true : !@obj.mentor_is_teacher 
    @a = a
    mail to: a.email, subject: 'Welcome to Gradians.com'
  end

  def new_suggestion(sg)
    @sg = sg 
    deadline = 3.business_days.from_now.in_time_zone('Kolkata') 
    mail to: @sg.examiner.account.email, subject: "( Typesetting Deadline ): #{deadline.strftime('%I:%M%p on %A, %b %d')}"
  end 

  def suggestion_received(sg)
    @deadline = 3.business_days.from_now # report in GMT to external parties
    @teacher = sg.teacher
    mail to: @teacher.account.email, subject: "( Gradians.com ): We have received your questions"
  end

  def suggestion_typeset( suggestion )
    t = Teacher.where(:id => suggestion.teacher_id).first 
    @name = t.first_name 
    @date = suggestion.created_at.to_date
    mail to:  t.account.email, subject:  "Your questions have been typeset"
  end

  def ask_question(account, question)
    mail subject:  "User Query", body:  question, to:  "help@gradians.com", :reply_to => account.email
  end

  def new_grading_work(eid)
    examiner = Examiner.find eid
    deadline = 3.business_days.from_now.in_time_zone("Kolkata") # IST 
    mail subject: "( Grading Deadline ):  #{deadline.strftime("%I:%M%p on %A, %b %d")}", to: examiner.account.email
  end

  def quiz_assigned(wsid)
    w = Worksheet.find wsid 
    @student = w.student
    unless @student.account.real_email.nil?
      @quiz = w.exam.quiz
      mail subject:  "( Gradians.com ): New homework posted to your account", to:  @student.account.real_email
    end
  end

  def registration_debug(city, state, zip, country)
    @city = city 
    @state = state
    @zip = zip 
    @country = country
    mail to:  "help@gradians.com", subject:  "registration debug"
  end

  def send_audit_report(question, author, gating_issues, non_gating_issues, comments)
    @gating_issues = gating_issues 
    @non_gating_issues = non_gating_issues 
    @comments = comments
    mail to:  author.account.email, subject:  "( Question Audit ): #{question.uid.upcase}"
  end

  def quiz_shared(quiz, from, to)
    @quiz_name = quiz.name
    @from_name = from.name
    @to_name = to.first_name
    mail to: to.account.email, subject: "( Gradians.com ): #{@from_name} has shared a quiz with you"
  end

  def worksheet_graded(ws)
    @student = ws.student
    @quiz = ws.exam.quiz
    mail to: @student.account.email, subject: "( Gradians.com ): Quiz '#{@quiz.name}' has been graded" 
  end

  def report_mint_error(obj, link)
    @type = obj.class.name
    @id = obj.id 
    @ref = link
    @during = (obj.job_id == WRITE_TEX_ERROR )? "Writing" : "Compiling"
    mail to: "bugs@gradians.com", subject: "( Gradians.com ): Error in Mint"
  end

  def new_sektion(sk)
    @t = sk.teacher
    @start = sk.start_date.strftime("%B %d, %Y") 
    @end = sk.end_date.strftime("%B %d, %Y")
    @renew = sk.auto_renew ? "Yes" : "No"
    @code = sk.uid
    @name = sk.name
    mail to: sk.teacher.account.email, subject: "( Gradians.com ): New section - #{@name} - created"
  end
 
  def inform_apprentice(a,bottomline, gating, nongating, comments)
    @a = a 
    @gating = gating 
    @nongating = nongating 
    @comments = comments
    mail to: @a.account.email, subject: "( Gradians.com ): #{bottomline}"
  end 

  def daily_digest(name, email, tbd_grading, tbd_disputes)
    @name = name 
    @tbd_g = tbd_grading 
    @tbd_d = tbd_disputes
    mail to: email, subject: "( Gradians.com ) - Pending work as of #{Date.today.strftime('%B %d, %Y')}"
  end

  def teacher_digest(t, n_days, details)
    @name = t.first_name 
    today = Date.today 
    @n = n_days
    @start_date = (today - n_days.days).strftime('%b %d, %Y')
    @end_date = today.strftime('%b %d, %Y')
    @details = details
    subj = n_days == 7 ? "Weekly synopsis" : "Monthly synopsis" 
    mail to: t.account.email, subject: "(Gradians.com): #{subj}"
  end 

  def upload_summary(t, details)
    @name = t.first_name 
    @details = details 
    mail to: t.account.email, subject: "(Gradians.com): Scans uploaded in last 24 hours"
  end 

  def reject_dispute(id, eid, reason)
    a = Tryout.find id
    quiz = a.worksheet.exam.quiz.name 
    ques = a.name?
    e = Examiner.find eid
    @exm = e.name
    @reason = reason
    mail to: a.student.account.email, subject: "(Dispute Rejected): #{ques} of '#{quiz}'"
  end

  def reupload_request(aid, reasons)
    a = Tryout.find aid 
    @s = a.student 
    @quiz = a.worksheet.exam.quiz.name 
    @question = a.name?
    @reasons = reasons
    mail to: @s.account.email, subject: "(Re-upload): #{@question} of #{@quiz}"
  end 

  def password_reset(account, new_passwd)
    @name = account.loggable.first_name
    @passwd = new_passwd
    mail to: account.email, subject: "Gradians.com: Password reset" 
  end

end
