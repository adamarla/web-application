class GradeDescriptionsController < ApplicationController
  before_filter :authenticate_account! 

  def new
  end

  def update
    redirect_to :back
  end

  def create
  end

end
