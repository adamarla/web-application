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

  def upload
    suggestiondoc = params[:suggestiondoc]
    tmp_file = suggestiondoc[:inputfile].tempfile
    extnsn = suggestiondoc[:inputfile].original_filename.split('.')[1]
    signature = File.size(tmp_file).to_s.concat('.').concat(extnsn)
    teacher_id = current_account.loggable_id

    unless Suggestion.where( :teacher_id => teacher_id ,
                         :signature => signature ).count == 0
      render :json => { :status => :duplicate , :message =>
        "You uploaded this exact same file before" }
    else

      payload = Base64.encode64(File.read(tmp_file))
      Delayed::Job.enqueue StoreSuggestion.new(teacher_id, signature, payload)
      render :json => { :status => :done ,
             :message => "Thanks! You will get an email as soon as the suggested questions have been typeset." }
    end
  end

end # of class 
