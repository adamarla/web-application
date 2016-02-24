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

  def by_day
    start_date = Date::strptime(params[:report_date], "%d/%m/%Y")
    days = (Date.today - start_date).to_i
    all_attempts = Attempt.where("created_at > ?", start_date)
    pids = all_attempts.map(&:pupil_id).uniq - Pupil.where(known_associate: true).map(&:id) # remove founders from list 
    pupils = Pupil.where(id: pids).sort{ |x,y| x.first_name <=> y.first_name }  
    
    by_user = []
    pupils.each do |p|
      attempts = all_attempts.where(pupil_id: p.id).group("attempts.created_at::date").count

      counts=Array.new(days, 0)
      attempts.each do |k, v|
        counts[(Date::strptime(k, "%Y-%m-%d") - start_date).to_i] = v
      end # of each attempt-day
      
      timed_attempts = p.attempts.where("total_time < 1800") # under 20 mins
      by_user << {
        name: p.name,
        counts: counts,
        attempts: p.attempts.count,
        avg_time: timed_attempts.count == 0 ? 0 : timed_attempts.map(&:total_time).inject(:+)/(timed_attempts.count*60)
      }
    end # of each pupil

    render json: { data: by_user, date: start_date }, status: :ok
  end # of method

  def by_week
    epoch = Date::strptime("16/11/2015", "%d/%m/%Y")
    known_assocs = Pupil.where(known_associate: true).map(&:id)

    by_week = []
    week_start = epoch
    until Date.today < week_start
      week_end = week_start + 6
      attempts = Attempt.where("created_at BETWEEN (?) AND (?) AND pupil_id NOT IN (?)", week_start, week_end, known_assocs)

      by_week << {
        name: "#{week_start.strftime('%d/%m')}-#{week_end.strftime('%d/%m')}",
        unique_users: attempts.map(&:pupil_id).uniq.count,
        num_attempts: attempts.count,
        time_spent: attempts.map{ |a| a.total_time.nil? ? 0 : (a.total_time > 900 ? 120 : a.total_time) }.inject(:+)
      }
      week_start = week_end + 1
    end
     
    render json: { data: by_week }, status: :ok
  end # of method

  def by_user
    pupil_ids = Pupil.where(known_associate: false).map(&:id)
    profiles = Pupil.profile(pupil_ids)
    render json: { data: profiles }, status: :ok
  end # of method

end

