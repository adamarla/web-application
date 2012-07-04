class SuggestionsController < ApplicationController
  def display
    @suggestion = Suggestion.where(:id => params[:id]).first
    head :bad_request if @suggestion.nil?
  end

  def block_db_slots
    num_items = params[:suggestion][:num_items].to_i + 1
    examiner = Examiner.where(:id => current_account.loggable_id).first
        
    suggestion = Suggestion.find params[:id]
    suggestion[:examiner_id] = examiner[:id]
    suggestion.save
        
    slots = examiner.block_db_slots( num_items, suggestion )
    render :json => {:slots => slots}, :status => :ok
  end

end
