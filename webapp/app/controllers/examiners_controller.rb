class ExaminersController < ApplicationController
  before_filter :authenticate_account!

  def show
    @me = current_account.loggable
  end

end
