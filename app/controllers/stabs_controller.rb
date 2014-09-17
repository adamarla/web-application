class StabsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def dates
    # Render the list of unique dates (oldest first) for
    # which there are stabs (for puzzles or questions). 
    # Obviously, they must have an accompanying scan

    type = params[:type]
    cnd = Stab.where(examiner_id: current_account.loggable_id).with_scan

    a = type.blank? ? cnd.ungraded : (type == 'graded' ? cnd.graded : cnd)
    @dates = a.map(&:uid).uniq
  end 

  def dated
    uid = params[:uid].to_i
    @stabs = Stab.where(uid: uid, examiner_id: current_account.loggable_id).order(:question_id, :version)
  end 

  def grade 
    # We get the stab from the kaagaz-IDs
    kgz_ids  = params[:kgz].keys.map(&:to_i)
    stab_id = Kaagaz.where(id: kgz_ids).map(&:stab_id).first # should be the same stab_id for all!
    
    all_good = Kaagaz.annotate params[:kgz]
    if all_good 
      stab = Stab.find stab_id 
      qlt = params[:stab][:quality].to_i
      stab.update_attribute :quality, qlt
    end 
    render json: { status: (all_good ? :success : :failed) }, status: :ok
  end 

  def graded
    # by default, graded stabs for the currently logged in student.
    # Else, stabs graded by passed examiner
    
    unless params[:e].blank?
      @stabs = Stab.graded.where(student_id: current_account.loggable_id)
    else
      @stabs = Stab.graded.assigned_to params[:e].to_i
    end 
    @uids = @stabs.map(&:uid).sort.uniq
  end 

end
