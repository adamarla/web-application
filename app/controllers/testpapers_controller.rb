class TestpapersController < ApplicationController

  def students
    # students who got this testpaper
    testpaper = Testpaper.find params[:id]
    head :bad_request if testpaper.nil?
    @students = testpaper.assignees
  end

end
