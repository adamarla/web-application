class TestpapersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def students
    # students who got this testpaper
    @testpaper = Testpaper.find params[:id]
    head :bad_request if @testpaper.nil?
    @students = @testpaper.students.order(:first_name)

    respond_with @students, @testpaper
  end

end
