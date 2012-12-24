class TestpapersController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def summary
    # students who got this testpaper
    @testpaper = Testpaper.find params[:id]
    head :bad_request if @testpaper.nil?
    @mean = @testpaper.mean?
    @students = @testpaper.students.order(:first_name)
    @answer_sheet = AnswerSheet.where(:testpaper_id => @testpaper.id)
    @max = @testpaper.quiz.total?
  end

  def load 
    @testpaper = Testpaper.find params[:id]
  end

end
