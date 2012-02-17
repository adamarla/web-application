class AccountsController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def update
  end

end
