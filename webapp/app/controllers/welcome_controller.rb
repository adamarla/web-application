class WelcomeController < ApplicationController
  def index
    unless current_account.nil? 
	  case current_account.role 
	    when :examiner, :admin 
		  redirect_to '/examiner'
		when :teacher 
		  redirect_to teacher_path
	  end 
	end 
  end

end
