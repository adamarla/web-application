class ExaminersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create 
    @examiner = Examiner.new params[:examiner] 
    username = @examiner.generate_username
    email = params[:examiner].delete(:email) || "#{username}@drona.com" 
    account = @examiner.build_account :email => email, :username => username, 
                                      :password => "123456", :password_confirmation => "123456"

    @examiner.save ? respond_with(@examiner) : head(:bad_request) 
  end 

  def show
    @examiner = Examiner.find params[:id] 
    head :bad_request if @examiner.nil?
  end

end
