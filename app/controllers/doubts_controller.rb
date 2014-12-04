class DoubtsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def pending 
    @dbts = Doubt.assigned_to(current_account.loggable_id).pending 
  end 

  def refund 
    dbt = Doubt.find params[:id]
    render json: { refund: (dbt.nil? ? :missing : ( dbt.refund ? :ok : :already ) ) }, status: :ok
  end 

  def preview 
    @dbt = Doubt.find params[:id]
  end 

end
