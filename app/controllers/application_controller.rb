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
    if current_account
      case current_account.loggable_type
        when "Teacher"
          is_new = current_account.loggable.new_to_the_site?
          t = current_account.loggable

          # Update info on which demos have been done and which remain
          cloned = t.quizzes.where{ parent_id >> PREFAB_QUIZ_IDS }
          json[:demo] = { 
            :build => (PREFAB_QUIZ_IDS - cloned.map(&:parent_id)), 
            :download => cloned.map{ |m|
              ws = m.testpapers.first
              ws = ws.nil? ? 1 : ws.id
              {
                :id => m.parent_id,
                :a => encrypt(ws,7),
                :b => m.id,
                :c => ws
              }
            }
          }
        else 
          is_new = false
      end
      json[:new] = is_new
      json[:who] = current_account.loggable_type
    end

    render :json => json, :status => :ok
  end

end
