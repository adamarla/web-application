class PodiumController < ApplicationController
  respond_to :json

  def ping 
    uid, qid, time = params[:user_id], params[:question_id], params[:time_to_bingo]

    # Handle the following two cases 
    #    1. the Android app might not yet know who the user is 
    #    2. the user might not have bingo-ed yet.
    # Nevertheless, if >= 1 attempts have been made for this same question, 
    # then there would be a leader-board 

    if uid > 0
      a = Attempt.where(user_id: uid, question_id: qid).first
      if a.nil?
        a = Attempt.create(user_id: uid, question_id: qid, time_to_bingo: time) # default time_to_bingo = 0 
      elsif (a.time_to_bingo == 0 && time > 0)
        a.update_attribute :time_to_bingo, time 
      end 
    end 

    # Run the query AFTER adding any new Attempt record for querying user. 
    attempts = Attempt.where(question_id: qid).where('time_to_bingo > ?', 0).order(:time_to_bingo)
    mine = attempts.where(user_id: uid).first 
    posn = mine.nil? ? 0 : attempts.index(mine) + 1 # 1-indexed

    # Send back info on the top-5 fastest times  
    list = [] 
    attempts.first(5).each_with_index do |a, i|
      highlight = (posn == i+1)
      name = highlight ? "You" : a.user.name 
      time_to_bingo = a.time_to_bingo
      list << { name: name, time: time_to_bingo, posn: i+1, highlight: highlight }
    end 

    # If user is outside top-5.
    if posn > 5 # => mine != nil => uid > 0
      list << { name:  "You", time: mine.time_to_bingo, posn: posn, highlight: true }
    end 

    render json: { podium: list }, status: :ok
  end 

end
