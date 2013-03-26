class SuggestionsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    if current_account && current_account.loggable_type == "Teacher"
      t = current_account.loggable 
      s = t.suggestions.build 

      p = params[:suggestion][:uploaded_doc]
      mime = Suggestion.mime_type p
      allowed, extension = Suggestion.valid_mime_type? mime

      if allowed
        uploaded_file = File.open(p.tempfile, "r")
        buffer = File.read uploaded_file 
        uploaded_file.close 
        sha_sum = Digest::SHA1.hexdigest(buffer)[0,12] # DB-has 15-character limit for signature
        payload = Base64.encode64 buffer
        Delayed::Job.enqueue StoreSuggestion.new(current_account.loggable_id, "#{sha_sum}.#{extension}", payload)
        render :json => { :notify => :submitted }, :status => :ok
      else
        render :json => { :notify => :invalid_file_type }, :status => :ok
      end
    else
      render :json => { :notify => :error }, :status => :ok
    end
  end

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
