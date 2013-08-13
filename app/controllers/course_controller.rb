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

  def load_milestone
    course = Course.find params[:course]
    unless course.nil? 
      milestone = Milestone.where(course_id: course.id).where(index: params[:index]).first
      unless milestone.nil?
        lessons = milestone.lessons.map{ |m| { id: m.id, name: m.name, badge: (m.history ? 'H' : 'L'), klass: :video } }
        quizzes = milestone.quizzes.map{ |m| { id: m.id, name: m.name, badge: m.total? } }
      else
        lessons = quizzes = []
      end
      @assets = lessons + quizzes
      render json: { assets: @assets }, status: :ok
    else # course NOT found !
      render json: { status: 'failed' }, status: :ok
    end
  end

  def available_assets
    course = Course.find params[:course]
    unless course.nil?
      show_lessons = params[:type] == "Lessons"
      available = show_lessons ? course.available_lessons : course.available_quizzes

      if show_lessons
        response = available.map{ |m| { id: m.id, name: m.name, badge: (m.history ? 'H' : 'L'), klass: :video } }
      else
        response = available.map{ |m| { id: m.id, name: m.name, badge: m.total? } }
      end
      render json: { assets: response, buttons: 'icon-resize-small' }, status: :ok
    else
      render json: { status: 'failed' }, status: :ok
    end
  end

end
