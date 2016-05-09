class UsagesController < ApplicationController
  respond_to :json 

  def update 
    usage = Usage.where(user_id: params[:id], date: params[:date]).first || 
             Usage.new(user_id: params[:id], date: params[:date], time_zone: params[:time_zone])

    if usage.new_record? 
      saved = usage.save 
    else 
      saved = usage.update_attributes time_on_snippets: params[:time_on_snippets],
                                      time_on_questions: params[:time_on_questions], 
                                      num_snippets_done: params[:num_snippets_done], 
                                      num_questions_done: params[:num_questions_done]
    end 

    render json: { updated: true }, status: (saved ? :ok : :internal_server_error)

  end # of method 

end # of class
