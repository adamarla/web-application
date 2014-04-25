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

  def list
    # going forward, factor in filters
    @courses = Course.all
  end

  def ping
    c = Course.find params[:id]
    render json: { id: c.id }, status: :ok
  end 

  def update
    c = Course.find params[:id]
    ids = params[:used].map(&:to_i)

    # before setting indices in the join table, ensure that only the assets
    # that need to be bound to the course are bound

    is_quiz = true
    if params[:type] == 'quizzes'
      c.quiz_ids = ids 
      joins = Takehome.where(course_id: c.id)
    else
      is_quiz = false
      c.lesson_ids = ids
      joins = Freebie.where(course_id: c.id)
    end

    # then, set the indices on the join table records
    ids.each_with_index do |i,j|
      if is_quiz 
        joins.where(quiz_id: i).first.update_attribute(:index, j)
      else
        joins.where(lesson_id: i).first.update_attribute(:index, j)
      end 
    end 
    render json: { status: :ok }, status: :ok
  end

  def quizzes
    @c = Course.find params[:id]
  end 

  def lessons
    @c = Course.find params[:id]
  end

end # of class
