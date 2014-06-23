class AttemptsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def grade
    sandboxed = !current_account.live?
    gid = params[:id].to_i
    g = Attempt.find gid
    criterion_ids = params[:criterion].keys.map(&:to_i)

    target = sandboxed ? current_account.loggable.doodles.create(attempt_id: gid) : g 
    target.grade(criterion_ids) unless target.nil? 

    # Now, store the comments 
    comments = params[:overlay].split("@d@").select{ |c| !c.blank? }
    target.annotate(comments) unless target.nil?

    render json: { status: :ok }, status: :ok
  end 

  def load_fdb 
    @g = Attempt.find params[:id]
    exm = @g.worksheet.exam
    sandboxed = params[:sandbox] == 'true'
    rubric = Rubric.find exm.rubric_id? 

    if sandboxed 
      doodle = Doodle.where(examiner_id: params[:a], attempt_id: @g.id).first 
      @criterion_ids = rubric.criterion_ids_given doodle.feedback
      @comments = Remark.where(doodle_id: doodle.id)
    else 
      @criterion_ids = rubric.criterion_ids_given @g.feedback
      on_this_page = @g.scan.nil? ? nil : Attempt.where(scan: @g.scan).map(&:id)
      @comments = on_this_page.nil? ? [] : Remark.where(attempt_id: on_this_page).live
    end 
  end 

end # of class
