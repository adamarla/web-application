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

  def show
    teacher = current_account.loggable
    @courses = Course.where(teacher_id: teacher.id).order(:price)
  end

  def outline
    render json: { status: :ok }, status: :ok
  end

end
