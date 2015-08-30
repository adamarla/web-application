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
      [:max_time, :time_to_answer, :time_on_cards, :time_in_activity].each do |k| 
        next if params[k].nil?
        attempt.update_attribute k, params[k]
      end

      render json: { id: attempt.id }, status: :ok
    else
      render json: { id: 0 }, status: :ok
    end 
  end # of method 

end
