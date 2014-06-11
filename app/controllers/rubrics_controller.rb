class RubricsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    nm = params[:rubric][:name]
    rb = Rubric.new name: nm, standard: (current_account.admin?), account_id: current_account.id
    if rb.save 
      render json: { rubrics: [{ name: rb.name, id: rb.id }] }, status: :ok
    else 
      render json: { status: :failed }, status: :bad_request  
    end 
  end 

  def list 
    is_admin = current_account.admin?
    @rb = Rubric.where('account_id = ? OR standard = ?', current_account.id, true)
  end 

  def load
    @rbid = params[:id].to_i
    is_admin = current_account.admin?
    aid = current_account.id 

    universal_set = (Criterion.where(account_id: aid) + Criterion.where(standard: true)).map(&:id).uniq
    used_ids = Checklist.where(rubric_id: @rbid, active: true).map(&:criterion_id)
    other_ids = universal_set - used_ids 

    @used = Criterion.where(id: used_ids).order(:penalty).reverse_order
    @available = Criterion.where(id: other_ids).order(:penalty).reverse_order
  end 
end
