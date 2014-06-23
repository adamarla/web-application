class CriteriaController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    d = params[:criterion]
    is_admin = current_account.admin?
    red_flag = d[:red_flag] == 'true' 
    orange_flag = (d[:orange_flag] == 'true') && !red_flag # one or the other - not both
    shortcut = (!is_admin || d[:shortcut].blank?) ? nil : d[:shortcut]

    @c = Criterion.new text: d[:desc], penalty: d[:penalty], standard: is_admin, 
                       account_id: current_account.id, shortcut: shortcut, 
                       red_flag: red_flag, orange_flag: orange_flag 
    if @c.save 
      # default to rendering through RABL
    else 
      render json: { result: :failed }, status: :ok
    end 
  end 
end
