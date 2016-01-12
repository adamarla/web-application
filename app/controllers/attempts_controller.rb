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

  def by_user
    report_for = params[:report]
    
    min_threshold = report_for[:threshold].to_i
    start_date = Date::strptime(report_for[:report_date], "%d/%m/%Y")
    days = (Date.today - start_date).to_i
    all_attempts = Attempt.where("created_at > ?", start_date)
    uniq_pupils = all_attempts.map(&:pupil).uniq
    
    by_user = []
    uniq_pupils.each do |up|
      attempts = all_attempts.where(pupil_id: up.id).group("attempts.created_at::date").count
      next if attempts.values.inject(:+) < min_threshold # at least these many attempts

      counts=Array.new(days, 0)
      attempts.each do |k, v|
        counts[(Date::strptime(k, "%Y-%m-%d") - start_date).to_i] = v
      end # of each attempt-day

      by_user << {
        name: "#{up.name}(#{up.attempts.count})",
        counts: counts
      }
    end # of each pupil

    render json: { data: by_user, date: start_date }, status: :ok
  end # of method

end
