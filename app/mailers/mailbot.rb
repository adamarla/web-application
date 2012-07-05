class Mailbot < ActionMailer::Base
  #default from: "from@example.com"
  default :from => "support@gradians.com" 
  layout 'mailbot'

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
    @testpaper = testpaper 
    @quiz = @testpaper.quiz
    @mean = @testpaper.mean?
    teacher = @quiz.teacher
    mail(:to => teacher.account.email, :subject => "(gradians.com) Testpaper graded") unless teacher.account.email.nil?
  end
  
  def suggestion_accepted(suggestion)
    teacher = Teacher.find( suggestion[:teacher_id] ).first
    @teacher_name = teacher.print_name
    @date = suggestion[:created_on]
    mail(:to => teacher.account.email, :subject => Suggestion accepted)
  end

end
