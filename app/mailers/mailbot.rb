class Mailbot < ActionMailer::Base
  default from: "mailer-noreply@gradians.com"
  layout 'mailbot'

  def curious_email(teacherform)
    mail subject:  teacherform[:email], 
      body:  teacherform[:text], to:  "akshay@gradians.com"
    mail subject:  teacherform[:email], 
      body:  teacherform[:text], to:  "abhinav@gradians.com"
  end

  def welcome_student(new_account)
    @account = new_account
    mail to:  @account.email, subject:  "Welcome to Gradians.com"
  end

  def welcome_teacher(new_account)
    @account = new_account
    mail to:  @account.email, subject:  "Welcome to Gradians.com"
  end
  
  def grading_done(exam)
    @exam = exam # need a object variable to pass to view
    @quiz = @exam.quiz
    @mean = @exam.mean?
    @max = @quiz.total?
    @submitters = @exam.submitters.count
    teacher = @quiz.teacher
    mail(to:  teacher.account.email, subject:  "(gradians.com) Assignment graded") unless teacher.account.email.nil?
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
    mail subject: "(Grading to-do) Deadline: #{d.strftime("%I:%M%p on %A, %b %d")}", to: examiner.account.email
  end

  def quiz_assigned(wsid)
    w = Worksheet.find wsid 
    @student = w.student
    unless @student.account.real_email.nil?
      @quiz = w.exam.quiz
      mail subject:  "[Gradians.com]: New homework posted to your account", to:  @student.account.real_email
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
    mail to:  author.account.email, subject:  "[Question Audit]: #{question.uid.upcase}"
  end

  def quiz_shared(quiz, from, to)
    @quiz_name = quiz.name
    @from_name = from.name
    @to_name = to.first_name
    mail to: to.account.email, subject: "[Gradians.com]: #{@from_name} has shared a quiz with you"
  end

  def scans_received(id)
    @teacher = Teacher.find id
    @deadline = 3.business_days.from_now.in_time_zone("Kolkata") # IST 
    mail to: @teacher.account.email, subject: "[Gradians.com]: Scans received for grading"
  end

  def worksheet_graded(ws)
    @student = ws.student
    @quiz = ws.exam.quiz
    mail to: @student.account.email, subject: "[Gradians.com]: Quiz '#{@quiz.name}' has been graded" 
  end

  def report_mint_error(obj, link)
    @type = obj.class.name
    @id = obj.id 
    @ref = link
    mail to: "bugs@gradians.com", subject: "[Gradians.com]: Error in Mint"
  end

end
