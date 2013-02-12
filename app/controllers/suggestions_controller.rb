class SuggestionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def block_db_slots
    n = params[:n].to_i
    suggestion = params[:sid].to_i

    Delayed::Job.enqueue BlockDbSlots.new(n,suggestion), :priority => 0, :run_at => Time.zone.now 
    render :json => { :notify => { :text => "#{n} slots blocked" } }, :status => :ok
  end

  def preview
    @suggestion = Suggestion.find params[:id]
  end

end # of class 
