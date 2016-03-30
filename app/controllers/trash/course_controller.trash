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

  def load 
    s = current_account.loggable # must be a student
    @c = Course.find params[:id]
  end 

  def update
    c = Course.find params[:id]
    ids = params[:used].blank? ? [] : params[:used].map(&:to_i)

    # before setting indices in the join table, ensure that only the assets
    # that need to be bound to the course are bound

    is_quiz = true
    if params[:type] == 'quizzes'
      c.update_quiz_list ids 
      joins = Takehome.where(course_id: c.id, live: true)
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
    @is_student = current_account.loggable_type == 'Student' 
    @c = Course.find params[:id]
    if @is_student
      sid = current_account.loggable_id
      not_compiled, compiling, compiled = @c.pre_check sid # quiz IDs

      w = Worksheet.of_student(sid)
      w_queued = w.select{ |j| compiling.include? j.exam.quiz_id }
      errored_out = w_queued.select{ |j| j.errored_out? }

      @queued = w_queued.map(&:id) - errored_out.map(&:id) 
      for e in errored_out
        e.destroy
      end 

      # Auto-compile all not_compiled quizzes. This is the right thing to do.
      # Students can have no way of knowing whether a quiz is worth compiling
      # or not. Hence, let them see the quizzes 

      for qid in not_compiled 
        q = Quiz.find qid 
        new_w = q.assign_to(sid, true) # take_home = true 
        @queued.push new_w.id 
      end 
      @disabled = @c.quiz_ids - compiled
      @ready = w.select{ |j| compiled.include?(j.exam.quiz_id) }
    end
  end 

  def lessons
    @c = Course.find params[:id]
  end

end # of class
