class Mailbot < ActionMailer::Base
  #default from: "from@example.com"
  default :from => "help@gradians.com" 
  layout 'mailbot'

  def suggestion_email(contact_form)
    mail :from => contact_form[:email], :subject => "Suggestion Email", 
      :body => contact_form[:text], :to => "help@gradians.com"
  end

=begin
  def grading_done_email(teacher)
    @account = teacher.account
    mail :to => @account.email, :subject => "Your assignment has been graded"
  end 
=end
  
  def welcome_email(new_account)
    @account = new_account
    me = @account.loggable
    if @account.trial
      t = TrialAccount.where(:teacher_id => me.id).first
      @password = t.zip_code
    else
      @password = me.school.zip_code
    end
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

end
