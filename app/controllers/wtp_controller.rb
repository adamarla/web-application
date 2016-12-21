
class WtpController < ApplicationController
	respond_to :json 

  def update 
    # Request made by mobile-app only. 
    wtp = Wtp.where(user_id: params[:uid]).first || 
          Wtp.create(user_id: params[:uid], price_per_month: params[:price_per_month])

    unless wtp.agreed 
      if params[:agreed] || params[:price_per_month] >= wtp.price_per_month
        wtp.update_attributes price_per_month: params[:price_per_month],
                              agreed: params[:agreed],
                              first_asked_on: params[:first_asked_on], 
                              agreed_on: params[:agreed_on],
                              num_refusals: params[:num_refusals]
      end 
    end 
    render json: wtp.decompile, status: :ok
  end 

end # of controller 
