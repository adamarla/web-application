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
    lgid = current_account.loggable_id
    @is_examiner = current_account.loggable_type == 'Examiner'

    if @is_examiner
      @stabs = Stab.where(uid: uid).assigned_to(lgid)
      @stabs = params[:type].blank? ? @stabs.ungraded : (params[:type] == 'graded' ? @stabs.graded : @stabs)
      @stabs = @stabs.order(:question_id, :version)
    else 
      @stabs = Stab.where(uid: uid, student_id: lgid).graded.order(:question_id)
    end 
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
    
    if params[:e].blank?
      @stabs = Stab.graded.where(student_id: current_account.loggable_id)
    else
      @stabs = Stab.graded.assigned_to params[:e].to_i
    end 
    @uids = @stabs.map(&:uid).sort.uniq
  end 

end
