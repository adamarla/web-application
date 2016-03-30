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

  def update 
    rb = Rubric.find params[:id]

    unless rb.nil?
      used = params[:used].map(&:to_i)
      rb.update_criteria used 
    end 
    render json: { result: :done }, status: :ok
  end 

  def list 
    is_admin = current_account.admin?
    @rb = Rubric.where('account_id = ? OR standard = ?', current_account.id, true)
  end 

  def load
    @rbid = params[:id].to_i
    # is_admin = current_account.admin?

    aid = current_account.id 
    @ctx = params[:context] # can be one of edit | grade | view

    if @ctx == 'edit'
      universal_set = (Criterion.where(account_id: aid) + Criterion.where(standard: true)).map(&:id).uniq
      used_ids = Checklist.where(rubric_id: @rbid, active: true).map(&:criterion_id)
      other_ids = universal_set - used_ids 

      @used = Criterion.where(id: used_ids).order(:penalty).reverse_order
      @available = Criterion.where(id: other_ids).order(:penalty).reverse_order
    else 
      @available = nil 
      @used = Rubric.find(params[:id]).criteria.order(:penalty).reverse_order
    end 
  end 

  def activate 
    # Only one rubric can be active at a time 
    r = Rubric.find params[:id]
    unless r.nil?
      others = Rubric.where(account_id: r.account_id)
      others.map{ |a| a.update_attribute(:active, false) }
      r.update_attribute :active, true
    end 
    render json: { status: :ok }, status: :ok
  end 

end
