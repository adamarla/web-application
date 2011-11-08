class WelcomeController < ApplicationController
  def index
    unless current_account.nil? 
	  case current_account.role 
	    when :examiner, :admin 
		  redirect_to '/examiner'
	  end 
	end 
  end

end
