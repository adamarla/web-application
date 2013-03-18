class ApplicationController < ActionController::Base
  include ApplicationUtil
  protect_from_forgery

  # [CanCan] : We have to redefine current_ability because our "user"
  # model is not called User, but is instead called "Account" 
  # Ref : https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability 
    @current_ability ||= AccountAbility.new(current_account)
  end 

  def ping
    if current_account
      case current_account.loggable_type
        when "Teacher"
          is_new = current_account.loggable.quizzes.count < 2
        else 
          is_new = false
      end
      render :json => { :deployment => Rails.env, :new => is_new, :who => current_account.loggable_type }
    else
      render :json => {:deployment => Rails.env}
    end
  end

end
