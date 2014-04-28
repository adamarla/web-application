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
        lessons = milestone.lessons.map{ |m| { 
          id: m.id, 
          name: m.name, 
          klass: 'video lesson', 
          video: m.video.uid } }

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
        response = available.map{ |m| { 
          id: m.id, 
          name: m.name, 
          klass: 'lesson', 
          video: m.video.uid } }
      else
        response = available.map{ |m| { id: m.id, name: m.name, badge: m.total? } }
      end
      render json: { assets: response }, status: :ok
    else
      render json: { status: 'failed' }, status: :ok
    end
  end

  def attach_detach_asset
    is_lesson = params[:type] == "Lesson"
    id = params[:id].to_i
    course = Course.find params[:course][:id]
    attach = params[:course][:operation] == "attach"

    unless course.nil?
      success = attach ? course.attach(id, is_lesson, params[:course][:milestone]) : course.detach(id, is_lesson) 
      render json: { status: (success ? :success : :failed) }, status: :ok
    else
      render json: { status: :failed }, status: :ok
    end
  end

end
