class DailyStreaksController < ApplicationController
  respond_to :json 

  def update 
    streak = DailyStreak.where(user_id: params[:id], date: params[:date]).first || 
             DailyStreak.new(user_id: params[:id], date: params[:date], 
                               streak_total: params[:total])

    saved = streak.new_record? ? 
      streak.save : streak.update_attribute(:streak_total, params[:total])

    render json: { updated: true }, status: (saved ? :ok : :internal_server_error)
  end 
end
