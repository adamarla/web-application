
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

  def get_by_user

    json = []
    Wtp.all.each do |u|
      json.push({
        id: u.user_id,
        pr: u.price_per_month,
        wl: u.agreed,
        nr: u.num_refusals,
        sp: u.agreed ? (Date.parse(u.agreed_on.to_s) - Date.parse(u.first_asked_on.to_s)).to_i: 0
      })
    end # of each
    render json: json, status: :ok
  end # of by_wtp

end # of controller 

