class WelcomeController < ApplicationController
  def index
    unless current_account.nil? 
      case current_account.role 
        when :examiner
          redirect_to '/examiner'
        when :admin 
          redirect_to '/admin'
        when :teacher 
          redirect_to teacher_path
        when :student 
          redirect_to student_path
        when :guardian 
          redirect_to guardian_path
      end 
    end 
  end
  
  def countries
    @countries = Watan.all
    render json: @countries
  end

  def faq
    render nothing: true, layout: 'faq' 
  end

  def report
    render nothing: true, layout: 'report'
  end

end
