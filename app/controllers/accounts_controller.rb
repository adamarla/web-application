class AccountsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def update
    account = Account.find params[:id]
    head :bad_request if account.nil?
    done = account.update_attribute :email, params[:account][:email]

    done ? render(:json => {:status => "new e-mail set"}, :status => :ok) : 
           render(:json => {:status => "update failed"}, :status => :bad_request)
  end

  def update_password
    # Ref: https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
    account = params[:account]
    failed = current_account.update_attributes(:password => account[:password], 
                                               :password_confirmation => account[:password_confirmation]) ? false : true
    sign_in current_account, :bypass => true unless failed
    failed ? render(:json => {:status => "update failed"}, :status => :bad_request) :
             render(:json => {:status => "new password set"}, :status => :ok) 
  end

end
