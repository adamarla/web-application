class AdminController < ApplicationController
  before_filter :authenticate_account!

  def show
    @admin = current_account.loggable
	@benchmarks = GradeDescription.all 
  end 
end
