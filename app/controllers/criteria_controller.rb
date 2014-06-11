class CriteriaController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    d = params[:criterion]
    is_admin = current_account.admin?
    @c = Criterion.new text: d[:desc], penalty: d[:penalty], standard: is_admin, account_id: current_account.id 
    if @c.save 
      # default to rendering through RABL
    else 
      render json: { result: :failed }, status: :ok
    end 
  end 
end
