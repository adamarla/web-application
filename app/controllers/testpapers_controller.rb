class TestpapersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def summary
    # students who got this testpaper
    @testpaper = Testpaper.find params[:id]
    head :bad_request if @testpaper.nil?
  end

end
