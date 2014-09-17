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
    @dep = Rails.env
    @puzzle = nil

    unless current_account.nil?
      obj = current_account.loggable 
      @blocked = current_account.login_allowed.nil? ? false : !current_account.login_allowed
    else # main landing page
      obj = nil 
      @blocked = false
      @puzzle = Puzzle.of_the_day
    end 

    @type = obj.nil? ? nil : obj.class.name
    @q = nil
    @e = nil
    @admin = false
    
    case @type
      when "Student"
        indie = current_account.loggable.indie?
        @newbie = !indie && (current_account.sign_in_count < 4) 
        @puzzle = Puzzle.of_the_day
      when "Teacher"
        @newbie = obj.new_to_the_site?

        if obj.indie 
          @type = "Online"
        else
          # Draw attention to quizzes and exams made today
          quizzes = Quiz.where(teacher_id: obj.id)
          @q = quizzes.select{ |q| q.compiling? || q.created_at.to_date == Date.today }
          @e = Exam.where(takehome: false).select{ |e| e.quiz.teacher_id == obj.id }.select{ |e| e.compiling? || e.created_at.to_date == Date.today }
          # @demos = quizzes.where(parent_id: PREFAB_QUIZ_IDS).where('uid IS NOT ?', nil).select{ |m| m.compiled? } 
        end
      when "Examiner"
        @newbie = !obj.live? 
        @admin = obj.is_admin
      else
        @newbie = false
    end
  end # of method
end
