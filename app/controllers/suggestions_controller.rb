class SuggestionsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    t = Teacher.find_by_id(params[:teacher_id])
    unless t.nil?
      s = t.suggestions.build 
      s[:signature] = params[:signature]
      s[:pages] = params[:num_pages].to_i

      e = Examiner.where(:is_admin => true).sort{ |m,n| m.suggestion_ids.count <=> n.suggestion_ids.count }.first
      s[:examiner_id] = e.id
      s.save
      render :json => { :status => :ok }
    else
      render :json => { :status => :error }
    end
  end

  def block_db_slots
    n = params[:n].to_i
    suggestion = params[:sid].to_i

    Delayed::Job.enqueue BlockDbSlots.new(n,suggestion), :priority => 0, :run_at => Time.zone.now 
    render :json => { :notify => { :text => "#{n} slots blocked" } }, :status => :ok
  end

  def preview
    @sg = Suggestion.find params[:id]
    @images = @sg.preview_images
  end

end # of class 
