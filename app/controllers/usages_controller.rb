class UsagesController < ApplicationController
  respond_to :json 

  def update 
    # Update usage record unconditionally with any data sent
    # back from the phone
    # 
    # We are, of course, assuming that the user has installed 
    # the app on one phone only and hence the probability 
    # data from one phone over-writing that from another is low 

    usage = Usage.where(user_id: params[:id], date: params[:date]).first || 
             Usage.create(user_id: params[:id], date: params[:date], time_zone: params[:time_zone])

    updated = usage.update_attributes time_on_snippets: params[:time_on_snippets],
                                    time_on_questions: params[:time_on_questions], 
                                    time_on_stats: params[:time_on_stats], 
                                    num_snippets_done: params[:num_snippets_done], 
                                    num_questions_done: params[:num_questions_done]

    # [1.0+]: New JSON fields  
    unless params[:num_snippets_clicked].blank? 
      updated = usage.update_attributes num_snippets_clicked: params[:num_snippets_clicked],
                                        num_questions_clicked: params[:num_questions_clicked]
    end 

    render json: { updated: true }, status: (updated ? :ok : :internal_server_error)
  end # of method 

end # of class
