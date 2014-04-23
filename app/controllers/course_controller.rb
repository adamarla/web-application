class CourseController < ApplicationController
  before_filter :authenticate_account!
  respond_to :json

  def create
    data = params[:course]
    c = current_account.loggable.courses.new title: data[:title], description: data[:description]
    if c.save
      render json: { name: c.title, id: c.id }, status: :ok 
    else
      render json: { status: :failed }, status: :ok
    end
  end

  def show
    teacher = current_account.loggable
    @courses = Course.where(teacher_id: teacher.id)
  end

  def quizzes
    @c = Course.find params[:id]
  end 

end # of class
