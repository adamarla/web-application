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
                                  time_on_cards: params[:time_on_cards],
                                  time_in_activity: params[:time_in_activity]
      else 
        attempt.update_attributes max_time: params[:max_time]
      end 

      # num_surrender 
      attempt.update_attribute(:num_surrender, params[:num_surrender]) unless params[:num_surrender].blank?
      render json: { id: attempt.id }, status: :ok
    else
      render json: { id: 0 }, status: :ok
    end 
  end # of method 

end
