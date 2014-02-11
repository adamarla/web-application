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
    @who = current_account.nil? ? nil : current_account.loggable_type
    @q = nil
    @e = nil
    
    case @who
      when "Student"
        @newbie = StudentRoster.where(:student_id => current_account.loggable_id).count < 1
      when "Teacher"
        t = current_account.loggable
        @newbie = t.new_to_the_site?

        if t.online 
          @who = "Online"
        else
          # Draw attention to quizzes and exams made today
          quizzes = Quiz.where(teacher_id: t.id)
          @q = quizzes.select{ |q| q.compiling? || q.created_at.to_date == Date.today }
          @e = Exam.where(takehome: false).select{ |e| e.quiz.teacher_id == t.id }.select{ |e| e.compiling? || e.created_at.to_date == Date.today }
          # @demos = quizzes.where(parent_id: PREFAB_QUIZ_IDS).where('uid IS NOT ?', nil).select{ |m| m.compiled? } 
        end
      else
        @newbie = false
    end
  end # of method

end



# Demos are available only to external teachers. Our own instructors don't need them
=begin
        unless t.online
          cloned = t.quizzes.where{ parent_id >> PREFAB_QUIZ_IDS }
          json[:demo] = {
            build: (PREFAB_QUIZ_IDS - cloned.map(&:parent_id)),
            download: cloned.map{ |m| 
              ws = m.exams.first
              ws = ws.nil? ? 1 : ws.id
              { id: m.parent_id, a: encrypt(ws,7), b: m.id, c: ws }
            }
          }
        end # of unless 
=end
