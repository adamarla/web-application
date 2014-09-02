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

end
