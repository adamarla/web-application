class TryoutsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def grade
    sandboxed = !current_account.live?
    gid = params[:id].to_i
    g = Tryout.find gid
    criterion_ids = params[:criterion].keys.map(&:to_i)

    target = sandboxed ? current_account.loggable.doodles.create(tryout_id: gid) : g 
    target.grade(criterion_ids) unless target.nil? 

    # Now, store the comments 
    comments = params[:overlay].split("@d@").select{ |c| !c.blank? }
    target.annotate(comments) unless target.nil?

    render json: { status: :ok }, status: :ok
  end 

  def load_fdb 
    @g = Tryout.find params[:id]
    exm = @g.worksheet.exam
    sandboxed = params[:sandbox] == 'true'
    rubric = Rubric.find exm.rubric_id? 

    if sandboxed 
      doodle = Doodle.where(examiner_id: params[:a], tryout_id: @g.id).first 
      @criterion_ids = rubric.criterion_ids_given doodle.feedback
      @comments = Remark.where(doodle_id: doodle.id)
    else 
      @criterion_ids = rubric.criterion_ids_given @g.feedback
      # on_this_page = @g.scan.nil? ? nil : Tryout.where(scan: @g.scan).map(&:id)
      @comments = @g.scan.nil? ? [] : Remark.where(tryout_id: @g.id).live.order(:id)
    end 
  end 

  def reupload 
    a = Tryout.find params[:id]
    unless a.nil?
      a.reset(false) # reset for good measure 
      a.update_attribute(:scan, nil)
      s = a.student
      reasons = params[:reupload][:reasons].select{ |j| !j.blank? }
      # Mailbot.reupload_request(a.id, reasons).deliver if s.account.has_email?
      Mailbot.delay.reupload_request(a.id) if s.account.has_email? 
    end 
    render json: { status: :ok }, status: :ok
  end 

end # of class
