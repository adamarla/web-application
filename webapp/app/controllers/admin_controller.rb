class AdminController < ApplicationController
  before_filter :authenticate_account!

  def show
    render :nothing => true, :layout => 'admin'
  end 

end
