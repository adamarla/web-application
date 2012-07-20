class SuggestionsController < ApplicationController

  def block_db_slots
=begin
    num_items = params[:suggestion][:num_items].to_i + 1
    examiner = Examiner.where(:id => current_account.loggable_id).first
        
    suggestion = Suggestion.find params[:id]
    suggestion[:examiner_id] = examiner[:id]
    suggestion.save
        
    slots = examiner.block_db_slots( num_items, suggestion )
    render :json => {:slots => slots}, :status => :ok
=end
    render :json => { :status => 'done' }, :status => :ok
  end

end # of class 
