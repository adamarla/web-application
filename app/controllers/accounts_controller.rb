class AccountsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def update
    account = Account.find params[:id]
    head :bad_request if account.nil?
    head (account.update_attribute(:email, params[:account][:email]) ? :ok : :bad_request)
  end

  def update_password
    account = params[:account]
    failed = current_account.update_attributes(:password => account[:password], 
                                               :password_confirmation => account[:password_confirmation]) ? false : true
    head (failed) ? :bad_request : :ok
  end

end
