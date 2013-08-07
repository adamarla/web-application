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
    json = {} 
    json[:deployment] = Rails.env

    user = current_account.nil? ? "unknown" : current_account.loggable_type

    case user
      when "Student"
        is_new = StudentRoster.where(:student_id => current_account.loggable_id).count < 1
      when "Teacher"
        t = current_account.loggable
        is_new = t.new_to_the_site?
        user = t.online ? "Online" : user

        # Demos are available only to external teachers. Our own instructors don't need them
        unless t.online
          cloned = t.quizzes.where{ parent_id >> PREFAB_QUIZ_IDS }
          json[:demo] = {
            build: (PREFAB_QUIZ_IDS - cloned.map(&:parent_id)),
            download: cloned.map{ |m| 
              ws = m.testpapers.first
              ws = ws.nil? ? 1 : ws.id
              { id: m.parent_id, a: encrypt(ws,7), b: m.id, c: ws }
            }
          }
        end # of unless 
      else
        is_new = false
    end

    json[:new] = is_new
    json[:who] = user

    render :json => json, :status => :ok
  end # of method

end
