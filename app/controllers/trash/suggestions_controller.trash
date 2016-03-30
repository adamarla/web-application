class SuggestionsController < ApplicationController
  before_filter :authenticate_account!, :except => [:create]
  respond_to :json

  def create
    tid = params[:teacher_id]
    teacher = tid.blank? ? nil : Teacher.find(tid)
    
    unless teacher.nil?
      assignee = Examiner.internal.available.sort{ |a,b| a.suggestion_ids.count <=> b.suggestion_ids.count }.first 
      sg = teacher.suggestions.create signature: params[:signature],
                                      pages: params[:num_pages].to_i,
                                      examiner_id: assignee.id
      render json: { status: :assigned }, status: (sg.nil? ? :bad_request : :ok)
    else
      render json: { status: :error }, status: :bad_request
    end
  end

  def block_db_slots
    n = params[:n].to_i
    suggestion = params[:sid].to_i

    Delayed::Job.enqueue BlockDbSlots.new(n,suggestion), priority: 0, run_at: Time.zone.now 
    render json: { notify: { text: "#{n} slots blocked" } }, status: :ok
  end

  def preview
    @sg = Suggestion.find params[:id]
    @images = @sg.preview_images
  end

end # of class 
