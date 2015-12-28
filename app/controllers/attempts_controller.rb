class AttemptsController < ApplicationController
  respond_to :json

  def update 
    attempt = Attempt.where(id: params[:id]).first || 
        Attempt.where(pupil_id: params[:pupil_id], question_id: params[:question_id]).first 

    if attempt.nil?
      unless params[:pupil_id] < 1
        attempt = Attempt.new(pupil_id: params[:pupil_id], question_id: params[:question_id]) 
        attempt.save
      end 
    end 

    # If 'attempt' is still nil, then something is amiss.
    unless attempt.nil?
      attempt.update_attributes num_attempts: params[:num_attempts], 
                          total_time: params[:total_time], 
                          max_opened: params[:max_opened], 
                          checked_answer: params[:checked_answer], 
                          got_right: params[:got_right],
                          seen_summary: params[:seen_summary]

      # While everyone is not on version >= 1.08 of the app 
      if params[:max_time].blank? # >= 1.08 
        attempt.update_attributes time_to_answer: params[:time_to_answer], 
                                  time_on_cards: params[:time_on_cards]
      else 
        attempt.update_attributes max_time: params[:max_time]
      end 

      update = [:num_surrender, :time_to_bingo]
      columns = {} 

      update.each do |key|
        next if params[key].blank?
        columns[key] = params[key]
      end 

      attempt.update_attributes(columns) unless columns.empty?
      render json: { id: attempt.id }, status: :ok
    else
      render json: { id: 0 }, status: :ok
    end 
  end # of method 

  def leaderboard 
    pid, qid, time = params[:pupil_id], params[:question_id], params[:time_to_bingo]

    # Handle the following two cases 
    #    1. the Android app might not yet know who the user is 
    #    2. the user might not have bingo-ed yet.
    # Nevertheless, if >= 1 attempts have been made for this same question, 
    # then there would be a leader-board 

    if pid > 0
      a = Attempt.where(pupil_id: pid, question_id: qid).first
      if a.nil?
        a = Attempt.create(pupil_id: pid, question_id: qid, time_to_bingo: time) # default time_to_bingo = 0 
      end 
    end 

    # Run the query AFTER adding any new Attempt record for querying user. 
    attempts = Attempt.where(question_id: qid).where('time_to_bingo > ?', 0).order(:time_to_bingo)
    mine = attempts.where(pupil_id: pid).first 
    posn = mine.nil? ? 0 : attempts.index(mine) + 1 # 1-indexed

    # Send back info on the top-5 fastest times  
    list = [] 
    attempts.first(5).each_with_index do |a, i|
      highlight = (posn == i+1)
      name = highlight ? "You" : a.pupil.name 
      time_to_bingo = a.time_to_bingo
      list.push { name: name, time: time_to_bingo, posn: i+1, highlight: highlight }
    end 

    # If user is outside top-5.
    if posn > 6 # => mine != nil => pid > 0
      list.push { name:  "You", time: mine.time_to_bingo, posn: posn, highlight: true }
    end 

    render json: { leaderboard: list }, status: :ok
  end 

end
