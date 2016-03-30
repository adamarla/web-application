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

  def tag 
    dbt = Doubt.find params[:id]
    tags = params[:doubt][:tags]
    is_tagged = false 
    unless dbt.nil?
      unless tags.blank?
        dbt.tag_list.add(tags, parse: true) 
        is_tagged = dbt.save 
      end 
    end
    render json: { tagged: is_tagged }, status: :ok 
  end 

end
