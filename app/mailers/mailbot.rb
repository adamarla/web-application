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
    @password = new_account.school.zip_code
    mail :to => @account.email, :subject => "Welcome to Gradians.com"
  end

end
