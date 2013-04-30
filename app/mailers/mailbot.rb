class Mailbot < ActionMailer::Base
  #default from: "from@example.com"
  default :from => "help@gradians.com" 
  layout 'mailbot'

  def curious_email(teacherform)
    mail :subject => teacherform[:email], 
      :body => teacherform[:text], :to => "akshay@gradians.com"
    mail :subject => teacherform[:email], 
      :body => teacherform[:text], :to => "abhinav@gradians.com"
  end

  def welcome_student(new_account)
    @account = new_account
    mail :to => @account.email, :subject => "Welcome to Gradians.com"
  end

  def welcome_teacher(new_account)
    @account = new_account
    mail :to => @account.email, :subject => "Welcome to Gradians.com"
  end
  
  def grading_done(testpaper)
    @testpaper = testpaper # need a object variable to pass to view
    @quiz = @testpaper.quiz
    @mean = @testpaper.mean?
    @max = @quiz.total?
    teacher = @quiz.teacher
    mail(:to => teacher.account.email, :subject => "(gradians.com) Testpaper graded") unless teacher.account.email.nil?
  end
  
  def suggestion_typeset( suggestion )
    t = Teacher.where(:id => suggestion.teacher_id).first 
    @name = t.first_name 
    @date = suggestion.created_at.to_date
    mail :to => t.account.email, :subject => "Your questions have been typeset"
  end

  def ask_question(account, question)
    mail :subject => "User Query", :body => question, :to => "help@gradians.com", :from => account.email
  end

end
