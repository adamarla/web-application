class CourseController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    data = params[:course]
    c = current_account.loggable.courses.new(name: data[:title], price: data[:price])
    if c.save
      render json: { status: :ok }, status: :ok
    else
      render json: { status: :failed }, status: :ok
    end
  end

end
